---
layout: default
title: Security (CRA, NIS2, SBOM)
nav_order: 6
---

# Security
{: .no_toc }

The [Cyber Resilience Act (CRA)](https://eur-lex.europa.eu/eli/reg/2024/2847/oj) is a regulatory framework established by the European Union to enhance the cybersecurity of digital products and services. 
It aims to ensure that manufacturers, developers, and distributors of digital products adhere to stringent security requirements throughout the product lifecycle.
The CRA mandates the implementation of robust security measures, regular updates, and transparent reporting of vulnerabilities to protect consumers and businesses from cyber threats.
CRA is built on existing regulations, such as the General Data Protection Regulation (GDPR), and complements other cybersecurity initiatives, such as the [NIS2 Directive](https://eur-lex.europa.eu/eli/dir/2022/2555).

* TOC
{:toc}

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


Vulnerabilities can usually come from different sources, such as:
- a vulnerability reported by a user or third-party, see [Report vulnerabilities](#report-vulnerabilities)
- a vulnerability reported by automated tools part of the regular security scans, see [Vulnerability process](#vulnerability-process)

### Report vulnerabilities

If you find a security vulnerability, please report it to the security team by writing an email to ``sviluppo@nethesis.it``
or by using GitHub dedicated security report tools:

- [NethServer and Nethvoice](https://github.com/NethServer/dev/security/advisories/new)
- [NethSecurity](https://github.com/NethServer/nethsecurity/security/advisories/new)

Please, **do not report security vulnerabilities as GitHub issues**.

#### Handling security vulnerabilities

The security team will evaluate the report and will contact the reporter to discuss the issue.
If the issue is confirmed, the handling process depends on the type of software:

- software produced and maintained by Nethesis
- software not produced by Nethesis (upstream projects)

##### Case 1: Software produced and maintained by Nethesis

For software developed and maintained by Nethesis, the vulnerability is handled in phases.
Each phase widens the group of people who know about it.
Until the full disclosure, the vulnerability details must not appear in public issues, public pull requests, forum posts or commit messages.

**Phase 1: restricted disclosure**

The vulnerability is explained only to a very small group of people:

- the three people responsible for the project: the [Product Manager](../management/#product-manager),
  the support team lead and the development lead
- the [developers](../management/#developer) needed to write and test the fix

The discussion happens in a private channel of the internal chat, open only to these people.
The explanation should cover the affected products and versions, the impact, how the vulnerability can be exploited and a first severity estimate.

**Phase 2: fix and release**

The fix follows the normal development process, with a few changes:

1. Open a draft [GitHub security advisory](https://docs.github.com/en/code-security/security-advisories/working-with-repository-security-advisories/creating-a-repository-security-advisory)
   in the affected repository. Write the details there, not in a public issue.
2. Write the fix inside the temporary private fork created from the draft advisory.
   If the fix has a low impact and does not reveal how to exploit the vulnerability, a public branch and pull request can be used instead.
3. Review and test the fix.
4. Release the fix as soon as possible. The fix usually includes new packages, modules or images.

**Phase 3: internal disclosure**

When the fix is released, the vulnerability is shared in the internal developers chat.
It can be shared earlier, if more people are needed to coordinate the release.

The coordination decides how the update reaches the systems. For example:

- available as a normal update, applied manually by administrators
- pushed to all systems at once
- rolled out in tiers, a group of systems at a time

**Phase 4: pre-disclosure communication**

After the release, a short communication invites everyone to update. It contains:

- few details: the affected product, the fixed version and the severity
- the link to the security advisory, which at this stage holds only generic information
- an invitation to update all machines as soon as possible

The communication is published on:

- the [community forum](https://community.nethserver.org)
- the [partner forum](https://partner.nethesis.it)
- the technical newsletter, when needed

**Phase 5: full disclosure**

The full disclosure happens at least 15 days after the pre-disclosure communication, to give users time to update their systems.
It is done by publishing the security advisory on GitHub with all the details and, if necessary, updating the forum posts.

**External reporters**

If the vulnerability is reported by someone outside Nethesis, the reporter is told that the disclosure will happen after 30 days.
The reporter is kept informed during the process and credited in the security advisory, unless they ask otherwise.

**Customer data**

If the vulnerability may have exposed customer data, for example on managed services, the internal privacy team must be involved during the disclosure.
The privacy team evaluates the legal obligations, like the notification of a personal data breach.
See also [Privacy by Design and by Default](../privacy/).

##### Case 2: Software not produced by Nethesis (upstream projects)

For software that is not developed by Nethesis but is part of an upstream project:

1. The security team will analyze the reported issue and verify if it is exploitable in the context of Nethesis products
2. If the issue is exploitable, the team will attempt to provide a temporary mitigation to protect users
3. The team will report the issue to the upstream project and collaborate with their developers to find a solution
4. Once a fix is available from the upstream project, the team will integrate it into the affected products and release an update

In both cases, the priority is to address vulnerabilities promptly and ensure the security of users.

## Vulnerability management workflow

The vulnerability management workflow is a structured approach to managing security vulnerabilities in software. It involves several key steps:

1. **Focus on released products**: Since builds occur in a protected environment, the primary focus is on vulnerabilities in released products.

2. **Automated identification**: The identification process is automated. Every night, the [SBOM Uploader](https://github.com/NethServer/nh-sbom/actions/workflows/sbom-uploader.yml) GitHub Action scans a list of configured repositories, retrieve the SBOMs, and uploads them to [Dependency Track](https://dependencytrack.org/). Nethesis maintains its own instance of Dependency Track at [https://dependencytrack.nethesis.it](https://dependencytrack.nethesis.it). Access to this platform is restricted to Nethesis employees; any employee can request an account for access.

3. **Vulnerability analysis**: Each project manager must allocate a minimum amount of time within the development process to analyze discovered vulnerabilities, focusing on critical and high-priority issues. It is recommended to allocate enough time every month for this task, including time for handling [EOL](#handling-end-of-life-eol).

4. **Monthly review meetings**: A monthly meeting is held where the project manager, along with developers, reviews the most critical vulnerabilities. Developers are responsible for determining whether these vulnerabilities are exploitable. If exploitable, the following steps are taken:
   - Attempt to update or fix the vulnerability.
   - If updating is not possible, document mitigation procedures thoroughly.

5. **Public disclosure**: It is the responsibility of the project manager to make this information public to inform users. Preferred channels for disclosure include:
   - [community.nethserver.org](https://community.nethserver.org)
   - [partner.nethesis.it](https://partner.nethesis.it)

6. **Critical vulnerabilities during development**: If critical vulnerabilities emerge during development, such as through GitHub advisories, the [Report vulnerabilities](#report-vulnerabilities) process is applied immediately.

## Handling End-of-Life (EOL)

Managing End-of-Life (EOL) for software, whether containerized or not, is a critical aspect of maintaining security and functionality. Below are some best practices to handle EOL effectively:

1. **Understand EOL does not imply vulnerabilities**: Software reaching EOL does not automatically mean it has vulnerabilities. However, it does mean that updates and support from the original developers will cease, increasing the risk over time.

2. **Best effort principle**: During the maintenance phase, developers attempt to update EOL versions when feasible. However, this is not always possible, especially for software relying on outdated libraries that can cause compatibility issues if updated.

3. **Commitment to critical vulnerabilities**: Developers commit to addressing critical and exploitable vulnerabilities, regardless of EOL status. If updates are not possible, mitigations must be documented (see below).

4. **Document mitigations**: When updates are not feasible, ensure that mitigations are clearly documented. This could include steps to isolate the software in a protected environment or other security measures.
Mitigation can be documented in the project manual or README file, ensuring users are aware of the risks and how to manage them.

5. **Use tools to track EOL**: Utilize tools like [endoflife.date](https://endoflife.date/) to monitor the EOL status of software and plan migrations or updates accordingly.

6. **Plan for migration**: Proactively plan for migrating to supported versions or alternative solutions before EOL is reached. This minimizes disruption and ensures continued security and functionality.

## Best practices

When creating software, it is essential to follow best practices to ensure security and maintainability.
Take a look at the [Best practices](best_practices.md) section for more details on how to create secure containers, manage dependencies, and implement testing.
