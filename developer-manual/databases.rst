=========
Databases
=========

Overview
========

All user-editable configuration parameters on NethServer are stored in
plain text database. 

These values are used to generate the system configuration files, such
as those found in the ``/etc/`` directory.
The configuration databases may be modified by various programs on the
system, including the web interface or scripts run from the command line
by a system administrator.

Each entry in the database is either a simple key/value pair or a key
and a collection of related property/value pairs.

Simple entries
==============

Simple configuration database entries take the form of a key/value pair:

::

    [root@nsrv -]# config show SystemName
    SystemName=myserver

Complex entries
===============

More complex entries consist of a key, a type, and a collection of
property/value pairs:

::

    [root@nsrv -]# config show sysconfig
    sysconfig=configuration
        Copyright=
        ProductName=NethServer
        Registration=none
        Release=4
        Version=6.4

Use complex entries whenever possible

Access from the command line
============================

You can access database entries from the command line using the
``config`` command, as shown above, or the ``db`` command. The
``config`` command provides a shorthand for accessing the
*configuration* database. The following commands are equivalent:

::

    [root@nsrv -]# config show SystemName
    SystemName=nsrv

    [root@nsrv -]# db configuration show SystemName
    SystemName=nsrv

The ``db`` command allows you to access all of the databases. For
example to show the details of the *test* entry from *accounts* db:

::

    [root@nsrv -]# db accounts show test
    test=user
        City=
        Company=
        Department=
        FirstName=test
        LastName=test
        PhoneNumber=
        Street=
        Uid=5000
        VPNClientAccess=yes
        VPNRemoteNetmask=255.255.255.0
        VPNRemoteNetwork=192.168.1.0
     

For more options see help of ``db`` command:

::

    db -h

Access via the Perl API
=======================

You can also access configuration database entries programmatically
using the ``esmith::ConfigDB`` and related Perl modules, which are
abstractions for the ``esmith::DB`` module.
For example, we can retrieve and show the admin account details like
this:

::

    use esmith::AccountsDB;
    my $db = esmith::AccountsDB->open or die "Couldn't open AccountsDB\n";
    my $admin = $db->get("admin") or die "admin account missing from AccountsDB\n";
    print $admin->show();

For documentation on Perl API use the ``perldoc`` command. Eg:

::

    perldoc esmith::ConfigDB

Database initialization
=========================

The configuration databases are initialized from files in the
``/etc/e-smith/db/`` hierarchy. These files can perform one of three
actions:

* Create a database entry and set it to a default value, if the entry
  does not already exist.
* Migrate an entry from a previous value to a new value.
* Force a database entry to a specific value, regardless of its current
  setting (**use with care!**)

This design allows each package to provide part of the system
configuration, or migrate the system configuration values as required.
Note that a single database property can only be owned by one package.
Database initialization is run during system install, system upgrade and
after new software has been installed.

If you examine the ``/etc/e-smith/db/configuration/`` directory you will
see three subdirectories: ``defaults/``, ``force/`` and ``migrate/`` to
match the three options above. A similar structure exists for each of
the other databases. A new database can be created by populating a new
directory tree under the ``/etc/e-smith/db/`` directory.

Configuration databases can also be initialized using a special 
``/usr/libexec/nethserver/initialize-<dbname>-database`` script, where *dbname* is the database name.
For example: ``/usr/libexec/nethserver/initialize-mycustomdb-database``.

Defaults files
--------------

Defaults files are simple text files. If the corresponding database
key/property already exists, it is skipped. Otherwise, the key/property
is created and the value loaded. For example, this file:

::

    [root@nsrv -]# cat /etc/e-smith/db/configuration/defaults/sshd/status
    enabled

It would create the ``sshd`` database entry if it doesn’t already exist,
create the ``status`` property for that entry, again if it doesn’t
already exist, and finally set the *status* property to ``enabled``.

Forcing database initialization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Simply call the action:
``/etc/e-smith/events/actions/initialize-default-databases``

Force files
-----------

Force files are just like defaults files, except they \ *overwrite*\    the existing value. So, this file:

::

    [root@nsrv -]# cat /etc/e-smith/db/configuration/force/sysconfig/Version
    6

It would create the *Version* property of the *sysconfig* entry and
unconditionally set its value to ``6``.

.. warning:: Do not use force fragments if not really necessary!

Migrate fragments
-----------------

Migrate fragments are small pieces of Perl text which can be used to
perform more complex migrations than is possible with defaults and force
files. They would normally be used to replace database keys or
properties with new names, or to adjust policy settings during an
upgrade.

Each fragment is passed a reference to the current database in the
``$DB`` variable. This variable is an instance of the appropriate
esmith::DB subclass, e.g. ``esmith::AccountsDB`` when the ``accounts``
database migrate fragments are being executed. This means that you can
use the methods of that subclass, for example
``esmith::AccountsDB->users()``.

Here is an example of a migrate fragment, which replaces the outdated
``popd`` entry with the new name ``pop3``:

::

    {
        my $popd = $DB->get("popd") or return;
        my $pop3 = $DB->get("pop3") ||   $DB->new_record("pop3", { type => "service" });
        $pop3->merge_props($popd->props);
        $popd->delete;
    }

This fragment checks whether the database (the configuration database in
this case) has a ``popd`` entry. If that entry does not exist, the
migrate fragment returns immediately. If the ``popd`` entry exists, we
need to convert it, so we retrieve the ``pop3`` entry (or create it if
it doesn’t already exist). We then merge the properties from the
``popd`` entry into the ``pop3`` entry and finally delete the ``popd``
entry.

If this migrate fragment is run again, it will return immediately as the
``popd`` entry has already been deleted.

Important notes about migrate fragments
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Please be careful with migrate fragments. Although they should only
  modify entries within the current database, there are no restrictions
  placed on what they can do. The ability to open and even modify other
  databases may be required to perform a migration.

* Migrate fragments must be safe to run multiple times. They should
  migrate the value when required and do nothing in other cases.
* Migrate fragments should never call ``croak`` or ``die``. This will cause the
  database migration to stop. If an error is detected, call ``carp`` or
  ``warn`` to note the error in the logs.
* Migrate fragments should call good termination with ``return(0)`` rather
  than ``exit(0)``.
* Migrate fragments should be owned by the package requiring the
  migration so that the migration only occurs when that package is
  installed.
* Migrate fragments should be self-contained and ideally perform only
  one migration per fragment.
* **DO NOT USE** to initialize default database values.

Evaluation order
================

When a database is loaded:

* migrate scripts are run first
* then defaults are loaded
* and finally any force files are loaded.

This order allows migration of old format entries to occur prior to
loading of new default values. Remember, defaults will not change an
existing database property.

Best practices
===============

* The configuration databases should only be modified using the tools
  and APIs provided.
* The order of the entries and the order of properties is undefined.
* The keys and property names are currently treated in a
  *case-sensitive*\  manner, though this may change in the future.
  *Do not create keys or property names which differ only by their
  case.* 
* Underscores and hyphens are valid in key and property names, but
  should normally be avoided.
* Do not "overload" an existing property with a new value. If the
  existing values do not meet your requirements, discuss your
  implementation with the developers. Values which are not known by the
  base may cause serious issues on upgrade. If the existing panels have
  three choices, do not invent new choices without enhancing the panel
  to support them.
* The ``type`` pseudo-property is used internally and is
  *reserved* .
* By convention, database keys are lower case, and property names are
  stored in mixed case. The ``type``, ``status`` and ``access``
  properties are exceptions to this convention.
* The storage location and internals of the databases is subject to
  change.
* The configuration databases are currently stored as pipe-delimited
  flat text files in the ``/var/lib/nethserver/db/`` directory.

Namespace issues
----------------

All entries in a single database share the same namespace. Users,
groups, information bays, printers, and other entries in the accounts
database currently all share one namespace. This means that you cannot
have a user with the same name as an information bay, group or other
entry in the accounts database.

However, it would be possible to have a host named *fredfrog* as well
as a user named *fredfrog* as they are stored in separate databases
and thus different namespaces.

List of available database
==========================

Table of databases
------------------

The following table summarizes

* the database name
* the perl module that manages it and
* the package that provides it


Databases provides by the base system:

================= ======================= ======================= ===================================================
Name              Perl module             Package                 Description 
================= ======================= ======================= ===================================================
configuration     esmith::ConfigDB        nethserver-base  
hosts             esmith::HostsDB         nethserver-hosts 
networks          esmith::NetworksDB      nethserver-base  
domains           esmith::DomainsDB       nethserver-mail-common
================= ======================= ======================= ===================================================


Each modules can define its own new databases. Some relevant databases are:

================= ======================= ======================= ===================================================
Name              Perl module             Package                 Description 
================= ======================= ======================= ===================================================
accounts          esmith::AccountsDB      nethserver-directory
domains           esmith::DomainsDB       nethserver-mail-common 
================= ======================= ======================= ===================================================


