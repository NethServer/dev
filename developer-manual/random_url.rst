=========================
Auto-generated random URL
=========================

Sometimes you need to install web applications which don’t have
built-in authentication.
A good solution can be an auto-generated random URL known only to some
special users. It’s also a best practice to restrict access to those
applications using Apache *allow* and *deny* rules.

This feature is implemented in *nethserver-lib* using
``genRandomHash`` function. The function will generate a SHA1 random
hash

Example from [[nethserver-collectd-web]]:

::

    my $alias = $collectd->prop('alias') || "";

    # initialize alias if needed
    if ($alias eq "") {
        $alias = esmith::util::genRandomHash();
        $confdb->set_prop('collectd-web','alias',$alias);
    }

Random alias should be generated inside an action, like
``<package_name>-conf``. The action must be executed before
template-expand in a position before 05.
Example from createlinks:

::

    my $event = "nethserver-samba-audit-update";

    event_actions($event, qw(
          initialize-default-databases 00
          nethserver-samba-audit-conf 02
    ));

