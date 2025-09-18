---
name: Bug report
about: Create a report to help us improve
labels: bug

---

**Steps to reproduce**

1. Install NethServer 8 version 3.10
2. Link the LDAP to a remote Samba AD of NethServer 7
3. Verify that LDAP users are browseable and accessible
4. Upgrade to NethServer 8 version 3.11
5. Attempt to browse LDAP users in the web interface
6. Open browser developer console and observe errors

**Expected behavior**

After upgrading from NethServer 8 version 3.10 to 3.11, LDAP users should remain browseable and accessible through the web interface without any errors. The password policy functionality should continue to work normally.

**Actual behavior**

After the upgrade to NethServer 8 version 3.11, LDAP users are no longer browseable in the web interface. In the browser developer console, the following error appears:

```
task get-password-policy Error: Request failed with status code 403
```

This suggests that the system is encountering a permission/authentication issue when trying to retrieve password policy information for LDAP users connected to the remote Samba AD.

**Components**

- NethServer 8 version 3.10 (working) → 3.11 (broken)
- LDAP integration module
- Remote Samba AD integration (source: NethServer 7)
- Web interface user management components
- Password policy API endpoints

To obtain specific package versions, run on the affected system:
```bash
rpm -qa | grep -F .ns8. | sort
```

**See also**

- This issue occurs specifically after upgrading from version 3.10 to 3.11
- The problem is related to LDAP users linked to remote Samba AD
- HTTP 403 error suggests an authorization/permission issue
- The issue affects the ability to browse users in the web interface

**Additional Information**

This appears to be a regression introduced in version 3.11 that affects LDAP integration with remote Samba AD domains from NethServer 7. The specific HTTP 403 error for the `get-password-policy` task indicates that the system may have changed how it handles authentication or authorization for password policy operations in the context of remote LDAP/AD integration.