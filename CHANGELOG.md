# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.2.0] - 2026-11-08

### Added

- `iam_members` (role => list of members, default `{}`): additive dataset
  grants via `google_bigquery_dataset_iam_member`, one resource per role and
  member. Rejects legacy `OWNER`/`WRITER`/`READER` roles, members without a
  `<type>:` prefix, `allUsers` and `allAuthenticatedUsers`. The dataset still
  declares no authoritative `access` block, so existing deployments plan the
  same.

### Changed

- CI: bump actions to their current majors, pin tool versions, and restrict the
  workflow token to `contents: read`.
- CI: add Dependabot for GitHub Actions and the Terraform provider.
- Docs: pin the README usage `source` to a release tag; fix the LICENSE year.

## [1.0.0]

Initial release (`v0.1.0` points at the same commit).

[Unreleased]: https://github.com/moveeeax/terraform-google-bigquery/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/moveeeax/terraform-google-bigquery/compare/v1.1.0...v1.2.0
[1.0.0]: https://github.com/moveeeax/terraform-google-bigquery/releases/tag/v1.0.0
