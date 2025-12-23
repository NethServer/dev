---
layout: default
title: Infrastructure Configuration
nav_order: 9
---

## Secure Infrastructure Configuration

The following best practices should be implemented to ensure secure configuration of infrastructure systems every time a new system is deployed.

### General Principles

1. **Adopt the principle of least privilege** for users, services, and network access.
2. **Document configurations and changes** for traceability and auditability.
3. **Review configurations periodically** and update them as needed.

### Operating System & Distribution

- **Choose up-to-date distributions**: When deploying on Linux, always use a version that is fully updated and with the furthest possible [End of Life](https://endoflife.date/) (EOL).
- **Regularly apply updates and patches**: Enable automated updates where possible and ensure all security patches are installed promptly.
- **Remove unnecessary components**: Uninstall or disable services, packages, and user accounts that are not strictly required.

### Network Security

- **Enable firewalls**: Activate the distribution’s firewall (e.g., `firewalld`, `ufw`), allowing only necessary ports. Alternatively, use and configure the cloud provider’s network firewall.
- **Use secure protocols**: Only allow encrypted and secure protocols (e.g., HTTPS, SSH, SFTP); disable plaintext services where feasible.
- **Always encrypt remote communications**: If an application needs to reach a remote resource (e.g., database or API), ensure the communication channel is always encrypted (e.g., TLS/SSL).
Use stunnel or VPN tunnels for sensitive data transfers when necessary.

### SSH and Authentication

- **Disable SSH password authentication**: Require SSH key authentication. All users needing SSH access must use their own key pair.
- **Restrict SSH to known IPs**: Access to SSH must be limited to a defined set of trusted addresses.
  Usually: `sos.nethesis.it` and company office IPs.
- **Do not allow root login**: Disable direct root login (`PermitRootLogin no`).
- **Rotate keys as needed** and regularly audit authorized keys.

### Monitoring and Metrics

- **Register systems for monitoring**: Every new system must be monitored through [metrics.nethesis.it](https://metrics.nethesis.it).  
  See [metrics-deploy repository](https://github.com/nethesis/metrics-deploy) for team configuration.
- **Set up automated alerts** for critical infrastructure events, such as login failures, disk space issues, or service outages (this is already included in the metrics.nethesis.it setup).
- **Centralize logs**: Forward relevant logs to a centralized logging system for audit and troubleshooting purposes.

### Backup

- **Implement regular backup routines**: Configure systematic backups for all systems using solutions documented at [nethinfra](https://github.com/nethesis/nethinfra/).
- **Encrypt backups** at rest and in transit, store them offsite when possible.
- **Test restore procedures** periodically to guarantee data recovery.

### Cloud and Virtual Infrastructure

- **Harden cloud accounts**: Use strong credentials and enable Multi-Factor Authentication (MFA) wherever supported. When using DigitalOcean, GitHub account with MFA is mandatory.
- **Control external exposure**: Regularly audit public IPs, open ports, and security group rules.
- **Manage resource lifecycle**: Remove unused or obsolete resources immediately.

### Additional Best Practices

- **Use configuration management tools** use Ansible to standardize and automate secure baseline enforcement.
- **Run vulnerability assessments**: Regularly scan systems for vulnerabilities with automated tools.
- **Maintain an updated asset inventory**: A list of deplyed systems is available inside metrics repository.
- **Remove unused users and groups**: Regularly audit accounts and revoke unnecessary access.