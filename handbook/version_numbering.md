---
layout: default
title: Version Numbering Rules
nav_order: 5
---

# Version Numbering Rules

The version numbering scheme is a set of rules that define how the version number is assigned to a release. The version number is a sequence of numbers separated by dots, for example, `1.2.3`.

All projects tries to follow the [Semantic Versioning](https://semver.org/) (semver) rules, but there are some differences between the projects.

## NethServer and NethVoice

NethServer and NethVoice releases follow a subset of Semantic
Versioning. Specifically, "build metadata"
syntax is not permitted because the `+` character conflicts with the
container image tag specification, as stated in [OCI
distribution-spec](https://github.com/opencontainers/distribution-spec/blob/main/spec.md#pulling-manifests).

The distinction between stable and pre-release versions is important in
the development process.

- **Stable releases** consist of three numbers separated by dots, e.g.,
  `1.2.7`. These represent the Major, Minor, and Patch numbers. For
  detailed explanations of these terms, refer to the [semver
  site](https://semver.org/). Stable releases are published and deployed
  to production systems.

- **Pre-releases or testing releases** include a pre-release suffix. This
  consists of a `-` (minus sign), a word, a dot `.`, and a number, e.g.,
  `1.3.0-testing.3`. Testing releases are meant for development. In rare
  cases, they can be used in production, but only if they address specific
  bugs requiring immediate resolution.

Releases can be automated using [gh ns8-release-module - GitHub CLI Extension](https://github.com/NethServer/gh-ns8-release-module).

### Update rules

Updates to NS8 core and modules (applications) must follow these rules:
0. New features, enhancements, and bug fixes must not change the behavior
   of existing systems.
0. New behaviors must be enabled through explicit and documented sysadmin
   actions.
0. Modules must support updates from any previous release within the same
   major release.

## NethSecurity

NethSecurity packages follow OpenWrt conventions.

OpenWrt roughly follows the semantic versioning rules, but with some differences:
- do not use pre-release version numbers
- do not use metadata version numbers

NethSecurity image versioning is documented [here](https://dev.nethsecurity.org/build/#versioning).