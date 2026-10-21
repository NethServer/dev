---
layout: default
title: Privacy by Design and by Default
nav_order: 7
---

# Privacy by Design and by Default
{: .no_toc }

* TOC
{:toc}

## Overview

NethServer projects are developed following the principles of **privacy by design** and **privacy by default**.

- **Privacy by design** means that data protection is considered from the first draft of a feature, not added at the end.
  Every feature that touches personal data must be designed to collect, store, and expose as little of it as possible.
- **Privacy by default** means that a fresh installation, a new module, or a new feature starts with the most privacy-friendly settings.
  Any extra data processing or data sharing must be an explicit choice of the administrator.

These principles come from:

- [General Data Protection Regulation (GDPR)](https://eur-lex.europa.eu/eli/reg/2016/679/oj), Article 25 "Data protection by design and by default"
- [Cyber Resilience Act (CRA)](https://eur-lex.europa.eu/eli/reg/2024/2847/oj), Annex I, Part I, which requires among others:
  a secure by default configuration (b), protection of the confidentiality of stored and transmitted data (e),
  processing only the data that is adequate, relevant and limited to what is necessary (g),
  and the possibility for users to securely and easily remove all data and settings (m)

See also the [Security](../security/) and [Environment Segregation](../environment_segregation/) sections.

### Roles

NethServer, NethVoice, and NethSecurity are mostly installed and operated by customers on their own infrastructure.
In this case the customer is the data controller and decides which personal data is processed.
Our responsibility as manufacturer is to give the customer software that makes compliance easy and safe by default.

When Nethesis runs a service that receives data from installations (for example subscriptions, remote support, or installation statistics),
Nethesis itself processes that data and the same rules apply even more strictly.

### What is personal data

Personal data is any information that relates to an identified or identifiable person. In our products it typically includes:

- user names, full names, email addresses, phone numbers
- IP addresses and MAC addresses linked to a user or a device
- call detail records, call recordings, voicemails, chat and fax content
- mailbox content, shared files, address books, calendars
- web proxy, DNS, VPN, and firewall logs that show what a user did and when
- authentication and audit logs

If in doubt, treat the data as personal.

## Privacy by design

When designing and implementing a feature, follow these rules.

1. **Collect only what is needed**: every piece of personal data must have a clear purpose.
   If a feature works without a field, do not collect it.
   Prefer aggregated or anonymized data (counters, totals) over per-user records.
2. **Keep it only as long as needed**: define a retention period for any personal data the feature stores, including logs.
   Provide an automatic cleanup or rotation mechanism and let the administrator change the period.
3. **Protect it**: personal data must be protected in transit and at rest.
   - use encrypted connections (TLS) for any network transfer, see [Cryptographic keys](../best_practices/#cryptographic-keys)
   - never store passwords in clear text, use hashes or the platform secret storage
   - restrict file and database permissions to the services that need them
   - apply the principle of least privilege to users, services, and API scopes
4. **Do not leak it in logs**: logs must not contain passwords, tokens, session IDs, message bodies, or recordings.
   Mask or truncate sensitive values. Use debug logs with more details only when explicitly enabled by the administrator.
5. **Pseudonymize where possible**: when an identifier is needed only to correlate events, use a pseudonymous ID (for example a salted hash)
   instead of the real name, email, or IP address.
6. **Allow deletion and export**: removing a user, a module, or an application must remove the related personal data, or clearly tell the
   administrator what is left and how to remove it. Data must be exportable in a common format, for example through backup.
7. **Avoid unnecessary third parties**: the software must not contact external services unless required by the feature.
   - the web UI must not load fonts, scripts, or images from external CDNs at runtime: bundle them
   - any connection to an external service (including Nethesis services) must be documented
   - prefer self-hosted and Open Source solutions, see [Selecting Open Source software](../best_practices/#selecting-open-source-software)
8. **Document it**: the developer documentation of each module must list which personal data is processed, where it is stored,
   how long it is kept, and whether it is sent to third parties.

## Privacy by default

The default configuration must be the most privacy-friendly one that still makes the product usable.

1. **Opt-in for extra processing**: features that process additional personal data must be disabled by default and enabled by the administrator.
   Examples: call recording, audit logs of user activity, mail archiving, detailed web proxy reports.
2. **Opt-in for data sharing**: sending personal data outside the installation must always require an explicit choice of the administrator.
   Anonymous technical data (for example version numbers used to check for updates) can be enabled by default only if it is documented
   and can be easily disabled.
3. **Short default retention**: logs and reports must have a default retention period. Do not keep data forever by default.
4. **Minimal exposure**: services and web interfaces must not be exposed to the public network unless the feature requires it.
   New user accounts must get the minimum set of permissions.
5. **No default credentials**: never ship default passwords. Generate random secrets during installation or ask the administrator to set them.
6. **Clear choices**: when the administrator enables a feature that processes personal data, the UI should explain in plain words
   which data is processed and why.

### Exceptions for the first configuration

In very rare cases, a default can be less strict to make the first configuration easier.
For example, a service may need to be reachable before the administrator has set up certificates or access rules.

When this happens:

- the choice must be justified and explained in the issue and in the pull request, and approved during the review
- the less strict default must be documented, together with the reason
- the administrator must be guided to a stricter configuration, inside the application (for example with a warning or a suggested action)
  or with specific documentation
- the less strict setting should be limited to what the first configuration really needs

## Development process

Privacy is part of the normal [development process](../):

- **Issues**: when a new feature processes personal data, the issue must describe which data is involved and why it is needed.
- **Design**: the UI/UX designer and the developer must apply the [privacy by default](#privacy-by-default) rules to new settings and pages.
- **Pull requests**: the reviewer must check the code against the [privacy by design](#privacy-by-design) rules, see the checklist below.
- **Testing**: real personal data must never be used outside production; use anonymized, masked, or synthetic data,
  see [Environment Segregation](../environment_segregation/).
- **Incidents**: a vulnerability that exposes personal data is handled as a security issue with maximum priority,
  see [Vulnerability management](../security/#vulnerability-management).

### Checklist

Use this checklist when designing a feature and when reviewing a pull request that touches personal data:

- [ ] Every personal data field has a clear purpose
- [ ] Data has a retention period and an automatic cleanup
- [ ] Data is encrypted in transit and secrets are not stored in clear text
- [ ] Logs do not contain passwords, tokens, or content of user messages
- [ ] Removing the user or the module removes the related data
- [ ] No external service is contacted without need, and any connection is documented
- [ ] New processing or data sharing is disabled by default
- [ ] Any less strict default is justified, documented, and the administrator is guided to a stricter configuration
- [ ] The module documentation lists the personal data processed
