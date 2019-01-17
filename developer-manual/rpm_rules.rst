=================
RPM package rules
=================

Naming and events conventions
=============================

Each package name MUST be composed of

* a prefix, corresponding to the product name: *nethserver-*, *neth-*, ....
* the feature/function/daemon/software: *base*, *directory*, *httpd-admin* ...

Each package **MUST** contain a ``<packagename>-update`` event, raised each time 
the package is installed/updated and when the system is re-configured (for instance,
after another package has been uninstalled). The update event should

* configure the package on first install
* take care of upgrading current installation in case of package update

.. note:: 

   You should not add code in ``%post`` and ``%pre`` sections of the spec file.
   All the logic must be inside the ``-update`` event.

Each package **MAY** contain a ``<packagename>-save`` event, raised by the console 
or the web interface to adjust the package configuration after some DB value has changed.

For example, given a package named **nethserver-dnsmasq**:

* update event: ``nethserver-dnmasq-update``
* save event: ``nethserver-dnmasq-save``

Install/Update process
======================

Just after a package transaction (install/update), the NethServer yum
plugin will:

* execute all nethserver-update-<package>: events of
  installed/updated packages in the current transaction
* execute ``runlevel-adjust`` event to start/stop all configured
  services
* execute ``firewall-adjust`` event to open/close firewall ports

In case of manual installation , the update, firewall-adjust and
runlevel-adjust events must be fired manually using the ``signal-event``
command.

Uninstall process
=================

After a package is removed, the NethServer yum plugin will:

* execute all nethserver-update-package event of installed packages
* execute runlevel-adjust event to start/stop all configured services
* execute firewall-adjust event to open/close firewall ports

Service packages
================

A service package is an RPM which is responsible for a system service
configuration and management.
The package must follow all rules listed above plus some more
conventions.

Configuration DB default
------------------------

Mandatory:

* type: service
* status: the current service status, can be enabled or disabled

Optional:

* TCPPort: a tcp listening port
* UDPPort: a udp listening port
* TCPPorts: a list of tcp listen ports. Eg: 123,678
* UDPPorts: a list of udp listen ports. Eg: 123,678

For example, the package nethserver-puppet managing the service puppet
will contain:

* /etc/e-smith/db/configuration/defaults/puppet/type
* /etc/e-smith/db/configuration/defaults/puppet/status

Beside this, each packge *MUST* always declare its own set of keys and properties inside default databases.

Events and actions
------------------

``nethserver-base`` package provides two generic events:

* ``runlevel-adjust``: enable/disable the service using
  chkconfig command and start/stop the service
* ``firewall-adjust``: read TCPPort(s) and UDPPort(s) props and open
  the specified ports in the firewall configuration

Both events are handled by the system, so there is **no need** to link
these events into the package.

Further documentation: ``perldoc /usr/share/perl5/vendor_perl/NethServer/Service.pm``

Orphan services
---------------

During runlevel-adjust event, the system will stop any orphan service.
A orphan service is a running service not controlled by any
nethserver-package.
A service is an orphan if there is a service record in configuration
db, and there is no db defaults (in `/etc/e-smith/db/configuration/defaults`).
