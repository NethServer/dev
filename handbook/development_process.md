---
layout: default
title: Development process
nav_order: 3
---

# Development process

* TOC
{:toc}

## General workflow

The development workflow for Nethesis projects involves several steps to ensure quality and efficiency. Here is a detailed description of the process:

1. **Bug or Feature Collection**: Issues are collected from internal channels (private chats, helpdesk) or external channels such as community forums.
2. **Issue Formalization**: The collected issues are formalized into GitHub issues. This task is usually delegated to a developer but can also be performed by other roles such as the project manager.
3. **Issue Assignment**: The issue is assigned to a developer who implements the solution in a separate branch and opens a pull request. If the issue requires changes to the user interface, the issue is assigned to a UI/UX designer before starting the development process.
4. **Code Review**: The code is subjected to a code review by one or more developers to ensure quality and adherence to coding standards.
5. **Pull Request Approval and Merge**: Once the pull request is approved, it is merged into the main branch.
6. **Automated Build and Test Process**: The build and test processes are automatically executed to verify the changes.
7. **Quality Assurance (QA)**: The output of the build process, whether a module or a package, is subjected to QA testing.
8. **Release or Rework**:
  - If the QA process is successful, the module or package is released, and the issue is closed.
  - If the QA process fails, the issue is returned to the developer for correction, and the process restarts from step 3.





## Module version numbering rules

NethServer 8 releases follow a subset of [Semantic
Versioning](https://semver.org/) (semver). Specifically, "build metadata"
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

- **Pre-releases or testing releases** include a prerelease suffix. This
  consists of a `-` (minus sign), a word, a dot `.`, and a number, e.g.,
  `1.3.0-testing.3`. Testing releases are meant for development. In rare
  cases, they can be used in production, but only if they address specific
  bugs requiring immediate resolution.







