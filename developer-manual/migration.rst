=====================================
Migration from NethService/SME Server
=====================================

Migration is the process to convert a SME Server (or NethService) machine into a NethServer.

#. In the old host, create a full backup archive and move it
   to the new NethServer host.
#. In the new server, install all packages that cover the same features of the old one.
#. Explode the full backup archive on some directory (for instance
   ``/var/lib/migration``)
#. Signal the event::

    signal-event migration-import /var/lib/migration

   This step will require some time.
#. Search for any ``ERROR`` string in ``/var/log/messages``


Coding conventions
==================

Most modules have already a migration action which handles the step
automatically.

A migration action:

* must be named as ``<packagename>-migrate``
* must be linked into ``migration-import`` event
* must migrate old properties values to new ones
* can copy original data files to the new location
* must take care to apply the imported configuration, possibly using
  the ``<packagename>-update`` event

During migration some properties will not be imported:
 
 * UDPPort, TCPPort, UDPPorts, TCPPorts: all network ports will be
   reset to new defaults
 * DNS forwarder, green IP address, default gateway: these properties
   are filled up in bootstrap-console

All e-smith databases are moved in ``/var/lib/nethserver/db`` directory.

Code snippets
-------------

A simple migrate action in perl.

.. code-block:: perl

  #!/usr/bin/perl
  use esmith::DB::db;
  use esmith::event;
  use strict;
  my $event = shift;
  my $sourceDir = shift;
  my $esmithDbDir = 'home/e-smith/db';
  my $errors = 0;
  if {
    die;
  }
  my $srcConfigDb = esmith::DB::db]>open\_ro(join('', $sourceDir, $esmithDbDir,'configuration')) || die("Could not open source configuration database in $sourceDir");
  my $dstConfigDb = esmith::DB::db->open || die;
  my $service = ‘ejabberd’;
  my $old = $srcConfigDb->get($service);
  my $new = $dstConfigDb->get || $dstConfigDb->new_record($service);
  $new->merge_props($old->props);
  # Apply configuration
  if( ! esmith::event::event_signal('nethserver-ejabberd-update')) {
   exit(1);
  }
  exit 0;



Remember to change the service name and add a license header.

Add the migrate action to createlinks::

  #-----------------------------------
  # actions for migration-import event
  #-----------------------------------
  $event ="migration-import";
  event_actions($event, '<packagename>-migrate' => 60);

Packages
========

Each packages with special migration notes is listed below.

nethserver-base
---------------

Properties not migrated:

* PasswordSet
* UnsavedChanges
* bootstrap-console
* dns
* sysconfig
* SystemMode
* green network configuration
* ActiveAccounts (moved to nethserver-directory, calculated on-the-fly)


nethserver-backup
-----------------

No migration is possible. The backup must be reconfigured.

nethserver-directory
--------------------

Home directories: user's home directoriy migrates into :file:`/var/lib/nethserver/home`,
admin's home directory migrates into :file:`/var/lib/nethserver/migration/admin`, and a symlink is created in :file:`/root/admin-migration-<TIMESTAMP>`.

nethserver-hylafax
------------------

After migration check the configuration of incoming fax notification.

nethserver-httpd
----------------

The ibay-virtualhost relation has been designed differently from SME/NethService.
An automatic migration is not always possible; the resulting configuration must be checked manually.

The `global-pw-remote'` case is currently not implemented in NethServer and is mapped as ``global-pw``. 
The reason is we do not want make distinctions between internal/external connections.


nethserver-mail-server
----------------------

During pseudonyms migration, 

* pseudonyms pointing to ``admin`` and ``shared`` accounts are mapped to ``postmaster``, as any other account not existing in destination AccountsDB.  Thus the resulting configuration requires post-migration supervision.
* recursive pseudonyms (pointing to another pseudonym) are flattened and a relation with a user or group account record is established.

Index of shared mailboxes is not migrated. Each user must re-share its own mail directory. 
To workaround this problem copy the original index file (:file:`/etc/dovecot/sharedmailbox/dict.db`) to the new location (:file:`/var/lib/nethserver/vmail/shared-mailboxes.db`) and restart dovecot.
See http://wiki2.dovecot.org/SharedMailboxes/Shared for more information.

Forbidden "\\" in folder names
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The dovecot plugin listplugin (http://wiki2.dovecot.org/Plugins/Listescape) is enabled, and uses backslash "\\" as escape character. If original folder names contains "\\", run the following command *after* post-migration mail synchronization, to rename them: ::

   find /var/lib/nethserver/vmail/ -type d -regex '.*\\.*' -prune | (while read -r SRC; do echo mv -iv "$SRC" "${SRC//\\/\\5c}"; done )


nethserver-mail-filter
----------------------

No wildcards expansions are supported by nethserver-mail-filter UI interface; only full mail addresses or domain names. The migration action must map email addresses in the form ``*domain.tld`` to domain names, and log a warning whenever another form of wildcard expansion is used.

Also recipient blacklists are not implemented and bayes DB is not migrated

