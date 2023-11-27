# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Remove `TTLAfterFinished` flag for Kubernetes 1.25 compatibility (enabled by default).
- Remove `ExpandPersistentVolumes` flag for Kubernetes 1.27 compatibility (enabled by default).
- Remove `logtostderr` for Kubernetes 1.27 compatibility (output is logged to stderr by default).

## [0.9.2] - 2023-11-15

### Fixed

- Minor fix and use of `--ignore-not-found` in IPAM.

## [0.9.1] - 2023-11-15

### Changed

- Bump `cilium` to `0.17.0`.
- Bump `coredns` to `1.19.0`.
- Enable renovate for `cilium` and `coredns`.


## [0.9.0] - 2023-11-08

### Changed

- :boom: **Breaking:** Switch from Ubuntu to Flatcar and start support ignition.

## [0.8.0] - 2023-10-31

### Added

- Add IPv4 addresses management (ipam) for WC's `kube-vip-cloud-provider`. If the ipPool is specified, currently one IP is requested from it
and is added to the end of the list for this controller. `kube-vip-cloud-provider` is part of our Service-lvl load balancer solution in WC and
at least 1 public IP is always needed for the ingress controller to be able to expose its stuff.

## [0.7.1] - 2023-09-04

### Fixed

- Remove leftover `helmchart` CRs.

## [0.7.0] - 2023-08-17

## [0.6.2] - 2023-08-01

### Changed

- Consolidate containerd `config.toml` into single file to address [#1737](https://github.com/giantswarm/roadmap/issues/1737)
- Add host OS user `nobody` to `root` group to enable node-exporter's `filesystem` collector to access the host filesystem.
- Bump `cilium` version to `0.10.0` 

## [0.6.1] - 2023-07-13

### Added

- Add a way to customize the timeout in `HelmRelease.spec`.
- Set value for `controller-manager` `terminated-pod-gc-threshold` to `125` ( consistent with vintage )
- Bump `cloud-provider-vsphere` version to `1.5.0` 

## [0.6.0] - 2023-07-04

### Added

- Add IPv4 addresses management (ipam) for WC's control planes.
- Add `connectivity.network.controlPlaneEndpoint.host` to `certSANs` list.
- Bind `kube-scheduler` metrics to 0.0.0.0.

## [0.5.1] - 2023-06-07

### Changed

- Bump the version of coredns-app to `1.16.0`

## [0.5.0] - 2023-05-22

### Changed

- :boom: **Breaking:** Stop deploying default network policies with the `cilium-app`. This means the cluster will be more locked down and all network traffic is blocked by default. Can be disabled with `network.allowAllEgress` setting. Requires `default-apps-vsphere@v0.9.2`.
- Bumped default k8s version to `1.24`, this might be :boom: **Breaking:**
- `.cluster.kubernetesVersion`: `v1.22.5+vmware.1` -> `v1.24.11`
- default machine template `ubuntu-2004-kube-v1.22.5+vmware.1` -> `ubuntu-2004-kube-v1.24.11`
- `.controlPlane.image.repository`: `projects.registry.vmware.com/tkg` -> `registry.k8s.io`
- Add audilog configuration.
- :boom: **Breaking:** Refactor api for network parameters to apply the standard interface for all providers.

### Fixed

- Set `/var/lib/kubelet` permissions to `0750` to fix `node-exporter` issue.

## [0.4.0] - 2023-04-24

### Added

- Add `MachineHealthCheck` for worker nodes.
- Add `loadBalancersCidrBlocks` parameter that is used by kube-vip for `LoadBalancer` services.
- Add `apiServer.certSANs` option.

### Changed

- Improve schema and ci values.
- :boom: **Breaking:** Change default pod network and service network to 10.244.0.0/16 and 10.96.0.0/16.
- :boom: **Breaking:** Install CoreDNS (`coredns-app`) using `HelmRelease` CR and stop deploying it with `cluster-shared` resource set.

### Fixed

- Set `.network.servicesCidrBlocks` value in Cluster CR.

### Removed

- Remove `cluster-shared` dependency.

## [0.3.1] - 2023-04-05

### Added

- Add `default-test` HelmRepository (catalog) for debugging.

### Changed

- Bump `cloud-provider-vsphere` version to `1.3.3`.

### Removed

- Remove unnecessary labels from HelmRepository CR.

## [0.3.0] - 2023-03-27

### Changed

- :boom: **Breaking:** Use cilium kube-proxy replacement.
- Bump `cloud-provider-vsphere` version to `1.3.2`.
- Use release name instead of `cluster.name`.
- Move `organization` to root level for uniformity.

## [0.2.1] - 2023-03-21

### Fixed

- Add missing files for CoreDNS configuration by cluster-shared.

## [0.2.0] - 2023-03-20

### Added

- Allow setting etcd image repository and tag.
- Set the default etcd version to 3.5.4 (kubeadm default is 3.5.0 which is not
  recommended in production).
- Set the default etcd image to retagged Giant Swarm one.

## [0.1.2] - 2022-05-09

## [0.1.1] - 2022-03-29

### Added

- Add CicleCI configuration.

## [0.1.0] - 2022-03-29

### Added

- Initial chart implementation.

[Unreleased]: https://github.com/giantswarm/cluster-vsphere/compare/v0.9.2...HEAD
[0.9.2]: https://github.com/giantswarm/cluster-vsphere/compare/v0.9.1...v0.9.2
[0.9.1]: https://github.com/giantswarm/cluster-vsphere/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/giantswarm/cluster-vsphere/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/giantswarm/cluster-vsphere/compare/v0.7.1...v0.8.0
[0.7.1]: https://github.com/giantswarm/cluster-vsphere/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/giantswarm/cluster-vsphere/compare/v0.6.2...v0.7.0
[0.6.2]: https://github.com/giantswarm/cluster-vsphere/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/giantswarm/cluster-vsphere/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/giantswarm/cluster-vsphere/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/giantswarm/cluster-vsphere/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/giantswarm/cluster-vsphere/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/giantswarm/cluster-vsphere/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/giantswarm/cluster-vsphere/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/giantswarm/cluster-vsphere/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/giantswarm/cluster-vsphere/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/giantswarm/cluster-vsphere/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/giantswarm/cluster-vsphere/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/giantswarm/cluster-vsphere/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/cluster-vsphere/releases/tag/v0.1.0
