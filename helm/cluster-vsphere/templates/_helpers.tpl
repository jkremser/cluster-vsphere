{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "infrastructureApiVersion" -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end -}}

{{/*
VSphereMachineTemplate is immutable. We need to create new versions during upgrades.
Here we are generating a hash suffix to trigger upgrade when only it is necessary by
using only the parameters used in vspheredmachinetemplate.yaml.
*/}}
{{- define "mtSpec" -}}
datacenter: {{ $.vcenter.datacenter }}
datastore: {{ $.vcenter.datastore }}
server: {{ $.vcenter.server }}
thumbprint: {{ $.vcenter.thumbprint }}
{{ toYaml .currentClass }}
{{- end -}}

{{- define "mtRevision" -}}
{{- $inputs := (dict
  "spec" (include "mtSpec" .)
  "infrastructureApiVersion" ( include "infrastructureApiVersion" . ) ) }}
{{- mustToJson $inputs | toString | quote | sha1sum | trunc 8 }}
{{- end -}}

{{/*
Common labels without kubernetes version
https://github.com/giantswarm/giantswarm/issues/22441
*/}}
{{- define "labels.selector" -}}
app: {{ include "name" . | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
cluster.x-k8s.io/cluster-name: {{ include "resource.default.name" . | quote }}
giantswarm.io/cluster: {{ include "resource.default.name" . | quote }}
giantswarm.io/organization: {{ .Values.organization | quote }}
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
{{- end -}}

{{/*
Common labels with kubernetes version
https://github.com/giantswarm/giantswarm/issues/22441
*/}}
{{- define "labels.common" -}}
{{- include "labels.selector" . }}
app.kubernetes.io/version: {{ $.Chart.Version | quote }}
helm.sh/chart: {{ include "chart" . | quote }}
{{- end -}}

{{/*
Create a prefix for all resource names.
*/}}
{{- define "resource.default.name" -}}
{{ .Release.Name }}
{{- end -}}

{{- define "securityContext.runAsUser" -}}
1000
{{- end -}}
{{- define "securityContext.runAsGroup" -}}
1000
{{- end -}}

{{- define "kubeletExtraArgs" -}}
{{- .Files.Get "files/kubelet-args" -}}
{{- end -}}

{{- define "containerdProxyConfig" -}}
- path: /etc/systemd/system/containerd.service.d/99-http-proxy.conf
  permissions: "0600"
  contentFrom:
    secret:
      name: {{ include "containerdProxySecret" $ }}
      key: containerdProxy   
{{- end -}}

{{- define "teleportProxyConfig" -}}
{{- if $.Values.internal.teleport.enabled }}
- path: /etc/systemd/system/teleport.service.d/99-http-proxy.conf
  permissions: "0600"
  contentFrom:
    secret:
      name: {{ include "containerdProxySecret" $ }}
      key: containerdProxy
{{- end }}
{{- end -}}

{{/*
Updates in KubeadmConfigTemplate will not trigger any rollout for worker nodes.
It is necessary to create a new template with a new name to trigger an upgrade.
See https://github.com/kubernetes-sigs/cluster-api/issues/4910
See https://github.com/kubernetes-sigs/cluster-api/pull/5027/files
*/}}
{{- define "kubeadmConfigTemplateSpec" -}}
{{ include "sshUsers" . }}
{{ include "ignitionSpec" . }}
joinConfiguration:
  nodeRegistration:
    criSocket: /run/containerd/containerd.sock
    kubeletExtraArgs:
      {{- include "kubeletExtraArgs" . | nindent  6}}
      node-labels: "giantswarm.io/node-pool={{ .pool.name }}"
files:
  {{- include "sshFiles" . | nindent 2}}
  {{- include "teleportFiles" . | nindent 2 }}
  {{- include "containerdConfig" . | nindent 2 }}
  {{- if $.Values.proxy.enabled }}
    {{- include "containerdProxyConfig" . | nindent 2}}
    {{- include "teleportProxyConfig" . | nindent 2 }}
  {{- end }}
preKubeadmCommands:
{{ include "sshPreKubeadmCommands" . }}
- /bin/test ! -d /var/lib/kubelet && (/bin/mkdir -p /var/lib/kubelet && /bin/chmod 0750 /var/lib/kubelet)
  {{- if $.Values.proxy.enabled }}
- systemctl daemon-reload
- systemctl restart containerd
  {{- if $.Values.internal.teleport.enabled }}
- systemctl restart teleport
  {{- end }}
  {{- end }}
postKubeadmCommands:
- usermod -aG root nobody # required for node-exporter to access the host's filesystem
{{- end -}}


{{- define "kubeadmConfigTemplateRevision" -}}
{{- $inputs := (dict
  "data" (include "kubeadmConfigTemplateSpec" .) ) }}
{{- mustToJson $inputs | toString | quote | sha1sum | trunc 8 }}
{{- end -}}

{{- define "mtRevisionByClass" -}}
{{- $outerScope := . }}
{{- range $name, $value := .currentValues.nodeClasses }}
{{- if eq $name $outerScope.class }}
{{- include "mtRevision" (merge (dict "currentClass" $value) $outerScope.currentValues) }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "mtRevisionByControlPlane" -}}
{{- $outerScope := . }}
{{- include "mtRevision" (merge (dict "currentClass" .Values.controlPlane.machineTemplate) $outerScope.Values) }}
{{- end -}}

{{/*
Generate a stanza for KubeAdmConfig and KubeAdmControlPlane in order to 
mount containerd configuration.
*/}}
{{- define "containerdConfig" -}}
- path: /etc/containerd/config.toml
  permissions: "0600"
  contentFrom:
    secret:
      name: {{ include "containerdConfigSecretName" $ }}
      key: registry-config.toml
{{- end -}}


{{- define "auditLogFiles" -}}
- path: /etc/kubernetes/policies/audit-policy.yaml
  permissions: "0600"
  encoding: base64
  content: {{ $.Files.Get "files/etc/kubernetes/policies/audit-policy.yaml" | b64enc }}
{{- end -}}

{{/*
Generate name of the k8s secret that contains containerd configuration for registries.
When there is a change in the secret, it is not recognized by CAPI controllers.
To enforce upgrades, a version suffix is appended to secret name.
*/}}
{{- define "containerdConfigSecretName" -}}
{{- $secretSuffix := tpl ($.Files.Get "files/etc/containerd/config.toml") $ | b64enc | quote | sha1sum | trunc 8 }}
{{- include "resource.default.name" $ }}-registry-configuration-{{$secretSuffix}}
{{- end -}}

{{- define "credentialSecretName" -}}
{{- include "resource.default.name" $ }}-credentials
{{- end -}}

{{/*
The secret `-teleport-join-token` is created by the teleport-operator in cluster namespace
and is used to join the node to the teleport cluster.
*/}}
{{- define "teleportFiles" -}}
{{- if $.Values.internal.teleport.enabled }}
- path: /etc/teleport-join-token
  permissions: "0644"
  contentFrom:
    secret:
      name: {{ include "resource.default.name" $ }}-teleport-join-token
      key: joinToken
- path: /opt/teleport-node-role.sh
  permissions: "0755"
  encoding: base64
  content: {{ $.Files.Get "files/opt/teleport-node-role.sh" | b64enc }}
- path: /etc/teleport.yaml
  permissions: "0644"
  encoding: base64
  content: {{ tpl ($.Files.Get "files/etc/teleport.yaml") . | b64enc }}
{{- end }}
{{- end -}}

{{- define "ignitionSpec" -}}
format: ignition
ignition:
  containerLinuxConfig:
    additionalConfig: |-
      storage:
        files:
        - path: /opt/set-hostname
          filesystem: root
          mode: 0744
          contents:
            inline: |
              #!/bin/sh
              set -x
              echo "${COREOS_CUSTOM_HOSTNAME}" > /etc/hostname
              hostname "${COREOS_CUSTOM_HOSTNAME}"
              echo "::1         ipv6-localhost ipv6-loopback" >/etc/hosts
              echo "127.0.0.1   localhost" >>/etc/hosts
              echo "127.0.0.1   ${COREOS_CUSTOM_HOSTNAME}" >>/etc/hosts
      systemd:
        units:
        - name: coreos-metadata.service
          contents: |
            [Unit]
            Description=VMware metadata agent
            After=nss-lookup.target
            After=network-online.target
            Wants=network-online.target
            [Service]
            Type=oneshot
            Restart=on-failure
            RemainAfterExit=yes
            Environment=OUTPUT=/run/metadata/coreos
            ExecStart=/usr/bin/mkdir --parent /run/metadata
            ExecStart=/usr/bin/bash -cv 'echo "COREOS_CUSTOM_HOSTNAME=$(/usr/share/oem/bin/vmtoolsd --cmd "info-get guestinfo.metadata" | base64 -d | grep local-hostname | awk {\'print $2\'} | tr -d \'"\')" > ${OUTPUT}'
        - name: set-hostname.service
          enabled: true
          contents: |
            [Unit]
            Description=Set the hostname for this machine
            Requires=coreos-metadata.service
            After=coreos-metadata.service
            [Service]
            Type=oneshot
            RemainAfterExit=yes
            EnvironmentFile=/run/metadata/coreos
            ExecStart=/opt/set-hostname
            [Install]
            WantedBy=multi-user.target
        - name: ethtool-segmentation.service
          enabled: true
          contents: |
            [Unit]
            After=network.target
            [Service]
            Type=oneshot
            RemainAfterExit=yes
            ExecStart=/usr/sbin/ethtool -K ens192 tx-udp_tnl-csum-segmentation off
            ExecStart=/usr/sbin/ethtool -K ens192 tx-udp_tnl-segmentation off
            [Install]
            WantedBy=default.target
        - name: kubeadm.service
          enabled: true
          dropins:
          - name: 10-flatcar.conf
            contents: |
              [Unit]
              # kubeadm must run after coreos-metadata populated /run/metadata directory.
              Requires=coreos-metadata.service
              After=coreos-metadata.service
              [Service]
              # Make metadata environment variables available for pre-kubeadm commands.
              EnvironmentFile=/run/metadata/*
        {{- if $.Values.internal.teleport.enabled }}
        - name: teleport.service
          enabled: true
          contents: |
            [Unit]
            Description=Teleport Service
            After=network.target
            [Service]
            Type=simple
            Restart=on-failure
            ExecStart=/opt/bin/teleport start --roles=node --config=/etc/teleport.yaml --pid-file=/run/teleport.pid
            ExecReload=/bin/kill -HUP $MAINPID
            PIDFile=/run/teleport.pid
            LimitNOFILE=524288
            [Install]
            WantedBy=multi-user.target
          {{- end }}
{{- end -}}
