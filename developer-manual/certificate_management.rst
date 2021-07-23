======================
Certificate Management
======================

*nethserver-base* provides a set of templates that output
PEM-formatted certificate parts:

*  *certificate/key* RSA private key
*  *certificate/crt* public certificate
*  *certificate/pem* both key+crt parts

Configuration is inside the ``configuration`` database. Example: ::

  pki=configuration
    KeyFile=
    CrtFile=
    ChainFile=
    CertificateDuration=365
    CommonName=


A certificate consumer daemon should expand those templates to its own
certificate paths, by installing the proper configuration under
``/etc/e-smith/templates.metadata``.

For instance *nethserver-httpd* adds the following template
configuration:

*  ``/etc/e-smith/templates.metadata/etc/pki/tls/private/localhost.key``

::

   TEMPLATE_PATH="certificate/key"
   OUTPUT_FILENAME="/etc/pki/tls/private/localhost.key"
   PERMS=0600
   UID="root"
   GID="root"

*  ``/etc/e-smith/templates.metadata/etc/pki/tls/certs/localhost.crt``

::

   TEMPLATE_PATH="certificate/crt"
   OUTPUT_FILENAME="/etc/pki/tls/certs/localhost.crt"
   PERMS=0600
   UID="root"
   GID="root"

Set ``OUTPUT_FILENAME``, ``PERMS``, ``UID`` and ``GID`` values according
to daemon configuration.

Default behavior
=================

By default, ``CrtFile`` and ``KeyFile`` properties have empty values. In
this case, ``nethserver-base`` generates a self-signed certificate
during ``nethserver-base-update`` event.

Default SELinux-aware certificate locations are:

* ``/etc/pki/tls/private/NSRV.key``: private key
* ``/etc/pki/tls/certs/NSRV.crt``: CA certificate

A daily cron job checks certificate validity. If expired, the
self-signed certificate is re-generated and ``certificate-update`` event
is signaled.

Default certificate duration is set to 365 days. To change it:

::

       db configuration setprop pki CertificateDuration 3650

The certificate Common Name is set to system FQDN. To override this
value type:

::

       db configuration setprop pki CommonName custom.cn

Let's Encrypt
=============

NethServer can request and renews Let's Encrypt (LE) certificates.
The main helper ``/usr/libexec/nethserver/letsencrypt-certs`` can be executed also from command line.

For more info, see: ::

  /usr/libexec/nethserver/letsencrypt-certs -h


Database properties under ``pki`` key inside ``configuration`` database:

- ``LetsEncryptMail``: (optional) registration mail for LE notifications
- ``LetsEncryptDomains``: comma-separated list of domains added to certificate SAN field
- ``LetsEncryptChallenge``: challenge to use for validating the certificate, default is ``http``.
  It accepts also values like ``dns-<provider>``. Where ``<provider>`` is the name of the DNS provider.
  See the full list of available DNS provider plugins by executing ``certbot -h certonly``.
  More info at https://certbot.eff.org/docs/using.html?highlight=dns#dns-plugins.

DNS challenge
-------------

To use the DNS challenge, follow these steps:

- install the required certbot plugin plugin using yum; to see the list of available package use ``yum search certbot-dns``
- set ``LetsEncryptChallenge`` property to correct DNS plugin
- configure all required properties accordingly to plugin documentation

When using the dns challenge, make sure to set extra properties accordingly to certbot configuration.
All properties for the dns challenge should be in the form ``LetsEncrypt_<certbot_option>``, where
``<certbot_option>`` is the option specific to certbot DNS plugin.

Digitial Ocean example
^^^^^^^^^^^^^^^^^^^^^^

1. Install the plugin:

   ::

     yum install python2-certbot-dns-digitalocean

2. Configure the challenge type:

   ::

     config setprop pki LetsEncryptChallenge dns-digitalocean

3. Configure required props accordingly to https://certbot-dns-digitalocean.readthedocs.io/en/stable/:

   ::

     config setprop pki LetsEncrypt_dns_digitalocean_token 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

4. Request certificate for domain ``myserver.nethserver.org``:

   ::

     /usr/libexec/nethserver/letsencrypt-certs -v -d myserver.nethserver.org

