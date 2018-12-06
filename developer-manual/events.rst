==================
Actions and events
==================

Actions
=======

An action is a program, frequently written in a scripting language,
which performs a single task. It is typically an encapsulation of a task
usually done by a system administrator, such as editing a configuration
file or reconfiguring a service. Actions are not called directly; they
are always called by signalling an event.

The actions are stored in the ``/etc/e-smith/events/actions/`` directory.
These actions are then linked into the relevant events as the same
action may need to be performed in more than one event.
To create a new action called *myaction* you simply create a program
to perform the action *myaction* and save it as
``/etc/e-smith/events/actions/myaction`` . Actions can be written in any
programming language, although additional platform support is provided
for Perl code.

An example action script is:

::

    #!/bin/bash
    /usr/sbin/lokkit --update

Action script parameters
------------------------

Action scripts are always called with at least one parameter; the name
of the current event. Many action scripts can be called with a single
additional parameter. This parameter is usually a configuration database
key, for example the username being modified.
Action scripts rarely require more than two parameters. The details
should be stored in the configuration database(s) and only the key
should be passed to the action scripts.
All configuration details must be stored in the configuration
databases and the database key passed as the parameter to the action.
This allows other scripts to be added to the event.

Since the system passes the name of the current event as the first
parameter, it is often beneficial to write action scripts which are
polymorphic based on the event name. For example, the code to create a
user and the code to modify an existing user may be only slightly
different and may well benefit from being in a single script. Example:

::

     use strict;
     my $event = $ARGV[0];
     my $myarg = $ARGV[1];

     exit 0;

.. note:: Whenever possible, avoid to call events from within action scripts.

Action code libraries
---------------------

To promote code reusability and components abstraction some Perl
modules are available under
:file:`/usr/share/perl5/vendor_perl/NethServer/` and
:file:`/usr/share/perl5/vendor_perl/esmith/`. For instance,

NethServer::Password

  Secret generation and persistent storage, under
  :file:`/var/lib/nethserver/secrets/`.

NethServer::Service 
  Service manager agnostic API. No matter if a service is managed by
  systemd, Upstart or SysV init script: use this API to gain control
  over it.

NethServer::Directory
  Access to LDAP, service accounts and ACL management, low-level user
  and group management.

NethServer::MailServer
  Obtain accounts and mail addresses relations. Manage IMAP ACLs.

esmith::templates
    Template processing and expansion.

esmith::events
  Event execution and tracking.

For more informations about a specific module, refer its
:command:`perldoc` documentation.


Events
======

Events are a mechanism which allows the system to trigger a set of
actions in response to actual events that happen on the system. When one
of the users interfaces modifies the configuration databases, it must
signal an event to regenerate the various server application
configuration files according to the new configuration.

**Note:** The user interface must never modify configuration files
directly. Neither should to the administrator from command line.

Each event is associated with a list of actions which should be
performed when the event occurs and is defined as a subdirectory of
``/etc/e-smith/events/`` containing symbolic links to the appropriate
actions, loosely modelled after the ‘’System V init’‘mechanism for
starting servers. For example, if you examine the
``/etc/e-smith/events/interface-update`` directory::

  [root@nsrv actions]# ll /etc/e-smith/events/interface-update/
  total 8
  lrwxrwxrwx. 1 root root   34 Feb  6 11:19 S04interface-config-adjust -> ../actions/interface-config-adjust
  lrwxrwxrwx. 1 root root   33 Feb  6 11:19 S25interface-config-reset -> ../actions/interface-config-reset
  lrwxrwxrwx. 1 root root   33 Feb  6 11:19 S30interface-config-write -> ../actions/interface-config-write
  lrwxrwxrwx. 1 root root   35 Feb  6 11:19 S70interface-config-restart -> ../actions/interface-config-restart
  lrwxrwxrwx. 1 root root   36 Feb  6 11:19 S75interface-config-hostname -> ../actions/interface-config-hostname
  drwxr-xr-x. 2 root root 4096 Feb  6 11:20 services2adjust
  drwxr-xr-x. 3 root root 4096 Dec 18 11:17 templates2expand



The symbolic links are given prefixes such as S15, S85, etc. to specify
the order in which the actions should be executed in a similar manner to
the System V init mechanism.
You can change the actions performed by an event by changing the links
in the event directory. You can also create a new event by creating
another subdirectory of ``/etc/e-smith/events/``.

Implicit actions
----------------

Most events contain two common tasks: expanding various templates and
adjusting (e.g. restarting) the relevant services. For this reason, two
implicit actions are included in all events. These implicit actions mean
that additional code does not need to be written to perform these common
tasks. The implicit actions are represented by entries in the
``services2adjust/`` and ``templates2expand/`` subdirectories.

services2adjust
^^^^^^^^^^^^^^^

The ``services2adjust/`` directory contains links mapping a specific
service to the action to perform on that service. For example, if
signalling the event in question requires that the ntpd service is
restarted, you simply include the link ntpd -> restart in the
``services2adjust`` directory. The implicit action services2adjust would
then restart the ntpd service. As an example, the ``services2adjust/``
directory for the ``nethserver-httpd-update`` event is shown below::

  # ls> l /etc/e-smith/events/nethserver-httpd-update/services2adjust/
  total 0
  lrwxrwxrwx. 1 root root 7 Oct 2 09:05 httpd -> restart

templates2expand
^^^^^^^^^^^^^^^^

The ``templates2expand/`` directory contains a list of the configuration
files which need to be regenerated from their templates. This list
consists of a collection of empty files with the same file name as the
configuration file to be expanded and in a heirarchy mirroring their
location on the system. For example, to expand templates for the
``/etc/samba/smb.conf`` configuration file, simply include the empty
file ``etc/samba/smb.conf`` in the ``templates2expand/`` directory of
the relevant event.

Order of implicit actions
^^^^^^^^^^^^^^^^^^^^^^^^^

The implicit actions are implemented by inserting the action script
``generic_template_expand`` early in the list of actions to be run in an
event and the ``adjust-services`` action near the end of the list.
You should normally link your action scripts in the range S10 to S80 so
that they occur after templates2expand and before services2adjust.

.. note:: The ``generic_template_expand`` action is currently run at
 **S05** and ``adjust-services`` is run at **S90**.

Signalling events
------------------
The ``signal-event`` program takes an event name as an argument, and
executes all of the actions in that event, providing the event name as
the first parameter and directing all output to the system log. It works
by listing the entries in the event directory and executing them in
sequence. So for example, the command: ::

  signal-event interface-update

will perform all the actions associated with the ``interface-update``
event, which is defined by the contents of the
``/etc/e-smith/events/interface-update/`` directory.

Events with arguments
^^^^^^^^^^^^^^^^^^^^^
So far we have described the following general principle throughout the
system; changes are made by altering the database values, then
signalling events. The actions triggered by each event typically
regenerate entire configuration files, taking into account the latest
configuration information.

However, some changes are best made incrementally. For example, consider
the user-create event. One of its actions updates the LDAP directory,
which it could do by deleting all of the users and recreating them based
on the updated ``accounts`` database. However, this is inefficient and
would lose any additional LDAP attributes which may have been stored. It
would be better to simply add the new user incrementally, using the
default LDAP schema.

But how is the action code to know which user was just added? The new
username is passed as an argument to the user-create event. This way the
action programs triggered by the user-create event have a choice. They
can either ignore the username argument and regenerate their output
based on the updated list of accounts, or they can pay attention to the
username argument, retrieve the rest of the information about the new
user from the ``accounts`` database, and perform the incremental work to
add the user.

.. note:: Action scripts should normally take at most two
  arguments. The first is always the event name. The second optional
  argument is a key into one of the databases.

Events are not currently serialized. In most cases overlapping events
will not cause issues, but caution should be exercised when events are
signalled from programs.

Standard events and their arguments
-----------------------------------

The table below summarises the key NethServer events and their argument
if required. Remember, each action script is always called with the
event name as the first argument. The arguments listed in this table are
provided as the second argument.

====================================== ====================================== ============================================================================
Event                                  Arguments                               Description
====================================== ====================================== ============================================================================
certificate-update                                                            The server public key certificate has been updated
group-create                           Group key                              Called when a group is created
group-delete                           Group key                              Called when a group is deleted
group-modify                           Group key                              Called when a group is modified
group-create-pseudonyms                                                       Signalled when the automatic creation of group email address is required
host-create                            Host key                               Called when a host is created 
host-delete                            Host key                               Called when a host is deleted
host-modify                            Host key                               Called when a host is modified
hostname-modify                                                               Called when the SystemName or DomainName keys have been modified
ibay-create                            Shared folder key                      Called when a shared folder is created
ibay-delete                            Shared folder key                      Called when a shared folder is deleted
ibay-modify                            Shared folder key                      Called when a shared folder is modified
interface-update                                                              Called when a network interface configuration is updated in networks db
logrotate-update                                                              Change default log retention and rotation policies
trusted-networks-update                                                       The set of trusted networks is changed
migration-import                       Path to migration directory            Import migration data from the given directory
notifications-save                                                            Set notification configuration (root forward, mail sender address)
password-expired                       Username, expire date                  The given username password will expire on expiredate
password-modify                        User key                               Called when a user password is modified
password-policy-update                 User key                               Called when the system password policy has been changed
post-backup-config                                                            Called after configuration backup end
post-backup-data                                                              Called after data backup end
post-restore-config                                                           Called after restore of configuration
post-restore-data                                                             Called after restore of data
pre-backup-config                                                             The pre-backup-config event creates consistent system state for the backup
pre-backup-data                                                               The pre-backup-data event creates consistent system state for the backup
pre-restore-config                                                            Called before restore of configuration
pre-restore-data                                                              Called before restore of data
pseudonym-create                       Pseudonym key                          Called when a pseudonym is created
pseudonym-delete                       Pseudonym key                          Called when a pseudonym is deleted
pseudonym-modify                       Pseudonym key                          Called when a pseudonym is modified
user-create                            User key                               Called when a user is created
user-cleanup                           User key                               Remove all user data
user-delete                            User key                               Called when a user is deleted
user-modify                            User key                               Called when a user is modified
user-create-pseudonyms                 User key                               Called when the automatic creation of user's email address(es) is required
user-lock                              User key                               Called when a user account is locked
user-unlock                            User key                               Called when a user account is unlocked
system-initialization                                                         Initialize all system after installation
software-repos-save                                                           Configure software repositories
====================================== ====================================== ============================================================================

Handling deletions
^^^^^^^^^^^^^^^^^^
When adding a user, the user is created in the ``accounts`` database,
and various actions, such as creating the Linux account, are performed
in the ``user-create`` event. However, when deleting a user, we want to
maintain the ``accounts`` database entry for as long as possible, in
case there is information which the actions in the ``user-delete`` event
might need in order to cleanly delete the users.
The system convention for handling deletions is:

* Change the type of the entry to mark it as being in the process of
  being deleted e.g. a’‘user’‘entry becomes a’‘user-deleted’‘entry.
* Signal the relevant deletion event - e.g.’‘user-delete’‘
* Remove the entry from the database, but only if the event succeeds.
  With this approach, the action scripts can decide whether to ignore
  the’‘user-deleted’’ entries when performing their tasks.

Event logs
----------

.. warning:: Output of event logs will be soon refactored!

All events, and all actions run by the event, are logged to the
``messages`` system log. Here is an example action log, which has been
formatted onto multiple lines to enhance readability::

 Feb 2 13:22:33 gsxdev1 esmith::event[4525]:
  S65sshd-conf=action|
  Event|remoteaccess-update|
  Action|S65sshd-conf|
  Start|1138846952 730480|
  End|1138846953 66768|
  Elapsed|0.336288

From this single log, we can see the action script name, which event it
was called in, when it started, ended and how long it took (0.34
seconds). Now, let’s add an action script which always fails and signal
the event again::

 Feb 2 16:11:54 gsxdev1 esmith::event[4787]:
  S99false=action|
  Event|remoteaccess-update|
  Action|S99false|
  Start|1138857114 58910|
  End|1138857114 81920|
  Elapsed|0.02301|
  Status|256

Note that this log has a new field Status, which is added if the action
script returns a false (non-zero) exit status. Suppressing the Status
field when it is zero (success) makes it much easier to find failed
actions in the logs.


.. warning:: If an action script fails, the entire event fails. The other
 actions scripts in the event are run, but the whole event is marked as
 having failed.

System validators
-----------------

System validators provide an extensible UI-independent data validation layer. 

On one hand UI implements fast grammar and/or syntax checks on input data. On the other, the system validators performs in-depth system consistency checks.  

Design
^^^^^^

Validators have a behaviour very similar to events.

* A validator is a directory inside ``/etc/e-smith/validators``. 
* Each validator directory has a descriptive name, eg. *user-name* for a validator which validate a new user name.
* A validator is composed by an arbitrary number of actions saved inside ``/etc/e-smith/validators/actions`` directory and linked inside validator directory.
* A success validation occurs when all scripts return 0 (success validation) or at least one script returns 2 (sufficient valid condition).

A validator action are always called with a single parameter which is the value to be validated. Actions must return one of these exit values:

* 0: successful validation
* 1: validation failed
* 2: sufficient validation
* other value: specific error state

When a script returns 2 (sufficient validation) no further script will be processed.

Inside *nethserver-devtools* package there is ``validator_actions()`` function which help creating links to actions just like ``event_actions`` function.  See ``perldoc esmith::Build::CreateLinks`` for details.

Invoking a validator::

  validate <validator-name> <value-to-validate>

Eg::

  validate user-name goofy
