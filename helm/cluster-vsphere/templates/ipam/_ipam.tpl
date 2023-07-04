{{/* vim: set filetype=mustache: */}}

{{- define "isIpamEnabled" -}}
    {{- if and (and (not .Values.connectivity.network.controlPlaneEndpoint.host) (.Values.connectivity.network.controlPlaneEndpoint.ipPoolName)) (.Capabilities.APIVersions.Has "ipam.cluster.x-k8s.io/v1alpha1/IPAddressClaim") }}
        {{- printf "true" -}}
    {{ else }}
        {{- printf "false" -}}
    {{- end }}
{{- end }}

{{/*
    The cluster.x-k8s.io/cluster-name label must not be added to IPAddressClaim resource,
    because the cluster-api-ipam-provider-in-cluster controller is trying to be smart and
    will not reconcile such claim if the associated cluster is being paused.
*/}}
{{- define "ipamLabels" -}}
    {{- $labels := include "labels.common" $ }}
    {{- $aux := mustRegexReplaceAll `(.*)` $labels "${1}," -}}
    {{- range $value := (split "," $aux)  }}
        {{- if not (hasPrefix "cluster.x-k8s.io/cluster-name" ($value | trim)) }}
            {{- printf "%s" $value -}}
        {{- end }}
    {{- end }}
{{- end }}
