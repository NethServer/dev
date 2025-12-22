---
layout: default
title: Environment Segregation
nav_order: 8
---

# Environment Segregation
{: .no_toc }

* TOC
{:toc}

## Overview

Key principles of environment segregation:

1. **Strict Separation:** Development, testing, and production environments must be strictly segregated, with access controls ensuring only authorized personnel can access each environment.
2. **Data Protection:** Real, sensitive, or personal data must never be used outside production; only anonymized, masked, or synthetic data is permitted in non-production environments.
3. **Controlled Deployment:** All changes to production must be tracked, reviewed, tested, and should bedeployed through automated workflows to ensure traceability, accountability, and compliance.

## Environment Definitions

- **Local Development:**  
  Initial development activities performed on individual developer machines.

- **Integration:**  
  The first environment where built artifacts are deployed and tested, including unit and integration tests. The integration environment usually has reduced resources compared to production.

- **Staging / Testing**  
  Comprehensive testing environment, including User Acceptance Testing (UAT), Quality Assurance (QA), penetration tests, and performance testing by both developers and product/business teams. The staging environment replicates production as closely as possible in terms of configuration but uses anonymized, masked, or synthetic data.

- **Pre-Production:**  
  An optional environment that closely mirrors production, used for final validation before deployment. Pre-production environments can be real environments provided by customers or internal teams. These environments are updated with the pre-production version and are actively monitored by a developer, who is available to assist and resolve issues as they arise.

- **Production:**  
  The live operational environment where software is accessible to end-users, with the highest degree of protection and segregation.

## Environment Segregation

- **Access Control:**  
  Each environment is segregated through centralized Identity and Access Management (IAM) policies, with distinct roles and permissions for each environment. IAM policies are reviewed regularly, and audit logs are retained through providers such as GitHub and DigitalOcean.

- **Production Access:**  
  Access to the production environment is strictly limited to a small number of authorized personnel. Developers are not allowed to promote changes to production independently.

- **Cloud Resource Access:**  
  Developers have access to cloud resources that mimic production resources for development and test purposes. These resources are separate and present different access levels and controls compared to production, which can only be accessed by specific users with proper authorization.

## Change Management & Deployment to Production

- **Git-tracked Changes:**  
  All changes to the production environment must be committed and pushed to a Git repository to ensure traceability and accountability of modifications.

- **Automated Deployment (where possible):**
  - Changes must be introduced via a Pull Request (PR) workflow.
  - Each PR must be reviewed and approved by an infrastructure administrator before being merged or deployed.
  - Changes can only be deployed after successful completion of automated and/or manual tests.
  - The deployment process should be automated where possible, ensuring consistency and minimizing human error.
  - Only approved and tested changes shall be deployed to the production environment.

## Access Types

Access to the organization's environments and resources is separated into three main categories:

- **Customer Cloud Resources:**  
  Cloud resources used in customer-facing production environments. Access is restricted to a select group of authorized users only.

- **Development Resources:**  
  Non-production resources and environments that emulate production for the purposes of development, integration, and testing. Developers are granted access as appropriate.

- **Infrastructure Resources:**  
  Underlying cloud and platform resources required for the operation and automation of the environments (e.g., CICD pipelines, infrastructure-as-code backends). Access is provided to operations and infrastructure teams as needed, and is kept distinct from both customer-facing and development resources.

## Data Management

- **Data Segregation:**  
  Production data is never used directly in development or testing environments. Staging and testing environments must employ data that is anonymized, masked, or synthetic.

- **Data Access:**  
  Access to production data is limited to specifically authorized personnel, each using unique credentials. Data movement between environments is monitored and strictly controlled.

## Compliance and Audit

- **Monitoring:**  
  All environments maintain comprehensive audit logs via cloud and platform providers (e.g. GitHub), recording access and configuration changes.

- **Notifications:**  
  Various types of notifications are sent when a new version is deployed to production. These notifications inform relevant stakeholders about the deployment event and may include details such as version number, deployment time, and any important release notes.
