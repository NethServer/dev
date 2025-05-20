---
layout: default
title: Security (CRA, NIS2, SBOM)
nav_order: 6
---

# Security

The [Cyber Resilience Act (CRA)](https://eur-lex.europa.eu/eli/reg/2024/2847/oj) is a regulatory framework established by the European Union to enhance the cybersecurity of digital products and services. 
It aims to ensure that manufacturers, developers, and distributors of digital products adhere to stringent security requirements throughout the product lifecycle.
The CRA mandates the implementation of robust security measures, regular updates, and transparent reporting of vulnerabilities to protect consumers and businesses from cyber threats.
CRA is built on existing regulations, such as the General Data Protection Regulation (GDPR), and complements other cybersecurity initiatives, such as the [NIS2 Directive](https://eur-lex.europa.eu/eli/dir/2022/2555).

## Essentials cybersecurity requirements

Essential cybersecurity requirements are a set of security measures that must be implemented by manufacturers, developers, and distributors of digital
products and services to comply with the Cyber Resilience Act. They are defined inside Annex 1, around page 68 of the CRA document:

- [CRA, English version](https://eur-lex.europa.eu/legal-content/EN/TXT/PDF/?uri=OJ:L_202402847)
- [CRA, Italian version](https://eur-lex.europa.eu/legal-content/IT/TXT/PDF/?uri=OJ:L_202402847)

## SBOM (Software Bill of Materials)

A SBOM (Software Bill of Materials) is a comprehensive inventory of all software components, libraries, and modules used in a project. It is essential for ensuring transparency, security, and compliance in software development. As part of the Cyber Resilience Act, maintaining an SBOM is crucial for identifying and mitigating vulnerabilities.

This inventory provides a detailed list of all dependencies, including version numbers, licenses, and known vulnerabilities. By generating an SBOM, developers can track and manage dependencies more effectively, reducing the risk of security breaches and ensuring compliance with licensing requirements.

SBOM helps to comply with the CRA requirements, such as the one defined in Annex 1.

Part 1:

> (a) be made available on the market without known exploitable vulnerabilities;

Part 2:

> (1) identify and document vulnerabilities and components contained in products with digital elements, including by
drawing up a software bill of materials in a commonly used and machine-readable format covering at the very least the
top-level dependencies of the products;

> (4) once a security update has been made available, share and publicly disclose information about fixed vulnerabilities,
including a description of the vulnerabilities, information allowing users to identify the product with digital elements
affected, the impacts of the vulnerabilities, their severity and clear and accessible information helping users to remediate
the vulnerabilities; in duly justified cases, where manufacturers consider the security risks of publication to outweigh
the security benefits, they may delay making public information regarding a fixed vulnerability until after users have
been given the possibility to apply the relevant patch;

We have chosen [Trivy](https://trivy.dev/latest/) as our tool for generating SBOMs. Trivy supports three output formats:

- **SARIF standard CVE**: This format is integrated into GitHub's code scanning feature, allowing for continuous vulnerability monitoring.
- **GitHub Dependency Graph format**: This format provides a snapshot of the current dependencies under the Insights tab but does not maintain a historical record.
- **CycloneDX**: This format should be included in the release with a filename ending in `.cdx.json`, providing a detailed and standardized SBOM.
  It also creates a historical record of dependencies.

When generating a SBOM of package, make sure to target all the software parts:

- the user interface (UI)
- the software itself that can be written in any language
- if the software is containerized, the container image including Linux distribution and software dependencies

See details on SBOM generation:

- [NethServer](https://nethserver.github.io/ns8-core/)
- [NethSecurity](https://dev.nethsecurity.org/) developer manual

## Updates

The priority is to release software without known exploitable vulnerabilities.

A known vulnerability does not necessarily mean it is exploitable.
When a CVE is reported on a released software, it should be analyzed and its impact evaluated.
Many known vulnerabilities often affect the build system or development dependencies, not the final product and can't be exploited.
There are also known vulnerabilities that are part of the Linux distribution where the software is running, but they are not exploitable in the context of the product.

### NethServer 8

NethServer 8 is a container-based solution. Each application is composed of one or more image containers.
So an application can be considered a package and can be easily updated by the user or automatically by the system.
This approach should ensure compliance with the Cyber Resilience Act, Annex 1 Part 2:

> c) ensure that vulnerabilities can be addressed through security updates, including, where applicable, through
automatic security updates that are installed within an appropriate timeframe enabled as a default setting, with
a clear and easy-to-use opt-out mechanism, through the notification of available updates to users, and the option to
temporarily postpone them;

The same apply to NethVoice which is an application of NethServer.

### NethSecurity

NethSecurity is based on Linux distribution OpenWrt which supports updates based on packages and also images.

Security policies and EOL of each release is documented inside [Security](https://openwrt.org/docs/guide-developer/security) page on the official Wiki.

NethSecurity follows the EOL policy of OpenWrt.

## Vulnerability management

Vulnerability management is a critical aspect of maintaining the security and integrity of digital products and services.
From CRA, Annex 1, Part 1:

> c) ensure that vulnerabilities can be addressed through security updates, including, where applicable, through
automatic security updates that are installed within an appropriate timeframe enabled as a default setting, with
a clear and easy-to-use opt-out mechanism, through the notification of available updates to users, and the option to
temporarily postpone them;

And Annex 1, Part 2:

> (5) put in place and enforce a policy on coordinated vulnerability disclosure;

The following guidelines are recommended for managing vulnerabilities on all products.

### Report vulnerabilities

If you find a security vulnerability, please report it to the security team by writing an email to ``sviluppo@nethesis.it``
or by using GitHub dedicated security report tools:

- [NethServer and Nethvoice](https://github.com/NethServer/dev/security/advisories/new)
- [NethSecurity](https://github.com/NethServer/nethsecurity/security/advisories/new)

Please, **do not report security vulnerabilities as GitHub issues**.

### Handling security vulnerabilities

The security team will evaluate the report and will contact the reporter to discuss the issue.
If the issue is confirmed, the handling process depends on the type of software:

- software produced and maintained by Nethesis
- software not produced by Nethesis (upstream projects)

#### Case 1: Software produced and maintained by Nethesis

For software developed and maintained by Nethesis, the following process applies:

1. Open a draft security advisory on GitHub
2. Assign the issue to the development team
3. The development team will work on the fix
4. The security team will review the fix
5. The fix will be released as soon as possible and announced to the users using community channels. The fix usually includes new packages along with a new image
6. Depending on the severity of the issue, the development team will decide how long to wait before a full disclosure, usually between 15 and 30 days, to give users time to update their systems

The disclosure will be done by publishing the security advisory on GitHub and, if necessary, updating the community channels.

#### Case 2: Software not produced by Nethesis (upstream projects)

For software that is not developed by Nethesis but is part of an upstream project:

1. The security team will analyze the reported issue and verify if it is exploitable in the context of Nethesis products
2. If the issue is exploitable, the team will attempt to provide a temporary mitigation to protect users
3. The team will report the issue to the upstream project and collaborate with their developers to find a solution
4. Once a fix is available from the upstream project, the team will integrate it into the affected products and release an update

In both cases, the priority is to address vulnerabilities promptly and ensure the security of users.

## Repository configuration

The repository configuration should follow some best practices to ensure the same level of security across all products.
Use Renovate for dependency management, while Dependabot only for alerts without automatic pull requests.

Access ``Settings`` -> ``Advanced Security`` then select the following options:
- ``Dependency graph``: enabled
  - ``Automatic dependency submission``: disabled
- ``Dependabot alerts``: enabled
- ``Dependabot security updates``: disabled
- ``Grouped security updates``: disabled
- ``Dependabot version updates``: disabled
- ``Dependabot on Actions runners``: enabled
- ``Code scanning``: disabled, feel free to enable it if you want to use it
- ``Secret protection``: disabled, feel free to enable it if you want to use it