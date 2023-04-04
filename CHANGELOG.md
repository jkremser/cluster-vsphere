# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/giantswarm/cluster-vsphere/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/giantswarm/cluster-vsphere/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/giantswarm/cluster-vsphere/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/giantswarm/cluster-vsphere/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/giantswarm/cluster-vsphere/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/giantswarm/cluster-vsphere/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/cluster-vsphere/releases/tag/v0.1.0
