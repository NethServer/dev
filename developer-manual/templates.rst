=========
Templates
=========

Design of the template system
=============================

Every piece of software has its own configuration format, and writing
parsers for each one is a complex, time-consuming and error-prone
process. The template system software avoids the whole issue by using
templates which *generate*  the correct configuration.

Configuration files are **over-written** 
when templates are expanded. In a few specific cases, the existing
configuration file is parsed and rewritten in-place. This is done where
the configuration file is also automatically updated
by some other process.

Templates are stored under ``/etc/e-smith/templates/`` in a directory
hierarchy which matches the standard filesystem. For example, the
template for ``/etc/inittab`` is stored in the
``/etc/e-smith/templates/etc/inittab/`` directory. Each template is stored
as a directory of template fragments and processed by the Perl
``Text::Template`` module.

The template fragments are concatenated together in *ASCIIbetical* 
order (US-ASCII sort order) and the complete file is parsed to generate
the appropriate configuration files for the service. The use of
fragments is part of NethServer modular and extensible
architecture; it allows third-party modules to add fragments to the
configuration where necessary.

The Text::Template module
=========================

The ``Text::Template`` module allows arbitary Perl code to be embedded in
a template file by surrounding it in curly braces (``{`` and ``}``). The code
inside the braces is interpreted and its return value replaces the
section between, and including, the braces. For instance::

  The answer is { 40 + 2 }

becomes::

  The answer is 42

Variables can be passed in from the program which is expanding the
template, hence::

 {
     $OUT = ';'
     for my $item ( qw(bread milk bananas) )
     {
          $OUT .= "\* $item\n";
     }
 }

would expand to::

   Shopping list
   * bread
   * milk
   * bananas

The template system uses this mechanism to automatically pass
in global configuration variables from the *configuration* database
which can then be used to fill out the configuration files.

For example, the ``/etc/hosts`` template could be fairly simple and composed of
two fragments::

 [root@test hosts]$ ls /etc/e-smith/templates/etc/hosts
 10localhost  20hostname

Fragments can have static content. For example, the first fragment::

 127.0.0.1       localhost

The second is more complex and relies on values from the configuration database::

 {
     $OUT .= "$LocalIP\t";
     $OUT .= " ${SystemName}.${DomainName}";
     $OUT .= " ${SystemName}";
 }

Note that the whole fragment is enclosed in braces. Within those braces
is a section of Perl code. 

When this template is expanded, it results in
the following configuration file::

 # ================= DO NOT MODIFY THIS FILE =================
 # 
 # Manual changes will be lost when this file is regenerated.
 #
 # Please read the developer's guide, which is available
 # at https://dev.nethesis.it/projects/nethserver/wiki/NethServer
 # original work from http://www.contribs.org/development/
 #
 # Copyright (C) 2015 Nethesis S.r.l. 
 # http://www.nethesis.it - support@nethesis.it
 # 
 127.0.0.1       localhost
 192.168.10.1    nsrv.nethesis.it nsrv


The header block comes "for free" as part of the template system,
courtesy of an optional file ``template-begin``, which is always processed
as the first fragment. If it isn't provided, the text shown with #
comments is included.
If target configuration file do not support line comment beginning with #, 
please provide a custom or empty ``template-begin``.

The other lines are provided by the two fragments shown above. Note the
use of the configuration database variables: ``$LocalIP``, ``$SystemName``
and ``$DomainName``. All simple entries in the configuration database are
provided as global variables to the templates.

Note that all of the template fragments are concatenated together before
evaluation, so it is possible to set values in fragments which are used
in later fragments. This is a very useful model for reducing the code in
individual template fragments.

The complex entries in the configuration database are also provided as
global variables to the templates. However, they are provided as Perl
hashes instead of simple scalars. For example, here is how you might
configure the Network Time Protocol (NTP) server ``/etc/ntp.conf`` file::

 server { $ntpd{NTPServer} }
 driftfile /etc/ntp/drift
 authenticate no

The *NTPServer* setting is stored in the *ntpd* configuration database
record, and so can be accessed via the hash accessor ``$ntpd{NTPServer}``.

template-begin and template-end
-------------------------------

Each template directory can contain two optional files ``template-begin``
and ``template-end`` . The template-begin file is always processed as the
first file of the template, and the template-end file is always
processed as the last file.

If the directory does not contain a ``template-begin`` file, the contents
of ``/etc/e-smith/templates-default/template-begin`` is used
automatically.

If the directory does not contain a ``template-end`` , nothing is appended
to the template output. It is mostly used to provide the closing block
for configuration files written in languages such as HTML and PHP,
through a link to an entry in the ``templates-default/`` directory.

/etc/e-smith/templates-default
------------------------------

The ``/etc/e-smith/templates-default`` directory contains a set of
template-begin and template-end files for various languages. For
example, if your template generates a perl script, you would link
``template-begin`` to ``/etc/e-smith/templates-default/template-begin-perl``
and automatically get the ``#!/usr/bin/perl -w`` line and a comment
containing the contents of the default template-begin file.

.. note:: You may also need a ``templates.metadata`` configuration file if your generated file needs to be executable.

Template fragment ordering
--------------------------

Template fragments are assembled in ASCII-betical order, with two
exceptions: template-begin always comes first, and template-end always
comes last. Template fragments are often named to start with a two digit
number to make the ordering obvious, but this is not required.

Templates for user home directories: templates-user
---------------------------------------------------

Most of the templates on the system map to single, fixed output files,
such as ``/etc/hosts``. However, templates are also used to generate
configuration files such as mail delivery instructions for users. These
templates are stored in the ``/etc/e-smith/template-user/`` tree.

As these templates have a variable
output filename, they are expanded using small pieces of Perl code in
action scripts.

Local site overrides: templates-custom and templates-user-custom
----------------------------------------------------------------

It is possible that the standard templates are not correct for a
particular installation, and so the local system administrator can
override the existing templates by placing files in the
``templates-custom`` tree. This is a parallel tree to the normal templates
hierarchy, and is normally empty. There is also a ``template-user-custom``
tree for overriding entries in the templates-user tree.
Be aware of overwriting all settings of a template if you copy the whole template to custom templates.
This means, if there is an update at the original template it is overritten with your old version at custom template.
If you only want to add a line to the config create an empty custom template and do it there.

.. warning: The template-custom trees is reserved for local system overrides. Software MUST NOT install files in this tree.

If a templates-custom entry exists for a template, it is merged with the
standard templates directory during template expansion, using the
following rules:

*  If a fragment of the same name exists in both templates and
   templates-custom, the one from templates-custom is used, and the one
   from the standard templates tree is ignored.
*  If the fragments in templates-custom have different names from those
   in templates, they are merged into the template as if they were in
   the templates directory.
*  If the templates-custom entry is a file, rather than a directory, it
   completely overrides the standard template.

To make this concrete, let's assume we have the following template
structure in ``/etc/e-smith/templates/etc/book.conf``::

 10intro
 30chapter3
 40chapter4
 80synopsis

and in ``/etc/e-smith/templates-custom/etc/book.conf``::

 30chapter3
 50chapter5

The resulting template would be processed in this order:

*  template-begin from /etc/e-smith/templates-default
*  10intro from /etc/e-smith/templates/etc/book.conf
*  30chapter3 from /etc/e-smith/templates-custom/etc/book.conf
*  40chapter4 from /etc/e-smith/templates/etc/book.conf
*  50chapter5 from /etc/e-smith/templates-custom/etc/book.conf
*  80synopsis from /etc/e-smith/templates/etc/book.conf
*  template-end (empty), nominally from /etc/e-smith/templates-default

How to resolve conflicts with standard templates
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is possible that the standard templates may specify behaviour which
is not appropriate for your application. In many cases the templates
will be driven by configuration database settings which allow their
behaviour to be customized, which should be the first thing to check.

In many cases, your application only needs to extend the behaviour
of the template by adding one or more fragments. This should be your
second option and can be achieved by simply adding your fragment in the
correct place in the list of fragments.

In rare cases the standard template specifies a behaviour which
conflicts with your application. In these cases, you should do **all** 
of the following:

*  Create a templates-custom directory to match the existing one in the
   templates hierachy.
*  Copy the conflicting fragment, and only that fragment, to the
   templates-custom directory. The fragment should have the same name in
   both directories. At this point you have not changed the behaviour of
   the system as the templates-custom entry will be preferred, but will
   behave identically.
*  Modify the copy in templates-custom to suit your required behaviour.
*  Inform the NethServer team about the problem.
   Please attach your modified template (or even better, a patch file)
   and provide details of why you think that the standard template
   should be changed.

The expansion of templates
--------------------------

To expand your custom templates to their destination you have to use the following command:

	expand-template <template destination>

where *template destination* has to be changed with the true path to the configuration file.

For Example you want to add something to the samba configuration, 
then you have to build a custom template fragment under
``/etc/e-smith/template-custom/etc/samba/smb.conf/`` directory
and execute the command:

	expand-template /etc/samba/smb.conf

Subdirectory templates
----------------------

It is also possible to split templates into further subdirectories. This
can be very useful for evaluating the same fragments in a loop, for
example for each virtual domain in ``httpd.conf`` or each ibay in
``smb.conf``.

Two examples of this can be found in
``/etc/e-smith/templates/etc/httpd/conf/httpd.conf/80VirtualHosts`` which
loops over the
``/etc/e-smith/templates/etc/httpd/conf/httpd.conf/VirtualHosts/``
directory, and ``/etc/e-smith/templates/etc/smb.conf/90ibays`` which
performs a similar loop over the
``/etc/e-smith/templates/etc/smb.conf/ibays/`` directory.

Template expansion
==================

The system is designed to ensure consistent and reliable operation,
without requiring command-line access. Whenever an event is signalled,
the relevant templates for that event are expanded and the services are
notified of the configuration changes.

Requesting expansion of a template in an event is a simple matter of
creating an empty file under the ``templates2expand`` hierarchy for that
event. 

See :ref:`events` manual chapter for further information.

Template permissions and ownership: templates.metadata
======================================================

Templates are normally expanded to be owned by ``root`` and are not
executable, which is a reasonable default for most configuration files.
However, templates may need to generate configuration files which are
owned by a different user, or which need to be executable or have other
special permissions. This can be done by creating a ``templates.metadata``
file which defines the additional attributes for the expansion.

.. note:: Configuration files should generally **not** be writable
 by any user other than root. In particular, configuration files should
 not normally be writable by the *www* user as this poses a significant
 security risk. Installation advice which says ``chmod 777`` is almost
 invariably wrong.

For example, here is the metadata file
``/etc/e-smith/templates.metadata/etc/ppp/ip-up.local``:

::

     UID="root"
     GID="daemon"
     PERMS=0755

which sets the group to ``daemon`` and makes the script executable. Note
that the file is readable by members of the ``daemon`` group, but it is
not writable by anyone but root. It is also possible to use the same
template to generate multiple output files, such as in this example:

::

     TEMPLATE_PATH="/etc/sysconfig/network-scripts/route-ethX"
     OUTPUT_FILENAME="/etc/sysconfig/network-scripts/route-eth1"
     MORE_DATA={ THIS_DEVICE => "eth1" }
     FILTER=sub { $_[0] =~ /^#/ ? '' : $_[0] } # Remove comments

The templates.metadata file for route-eth0 just uses ``eth0`` instead of
``eth1`` on the second and third lines. Note also the ``FILTER`` setting
which allows post-processing of the generated template.

There are many examples under ``/etc/e-smith/templates.metadata/`` and the
full list of options can be seen with:

``perldoc esmith::templates``

Template deletion: templates.metadata
=====================================

A template once expanded in the file system cannot be deleted automatically, 
you can only change its content. The template will still exist until you delete 
it by a ``templates.metadata`` file.

For example to delete ``/etc/myExample``, create the file 
``/etc/e-smith/templates.metadata/etc/myExample`` with just the following line ::

    DELETE=1

Then ::

    expand-template /etc/myExample
   


Perl API: processTemplate
==========================

In rare circumstances you may need to call ``processTemplate`` directly.
Explicit calls to ``processTemplate`` are typically only used when the
output filename is variable:

::

    use esmith::templates;
    foreach my $name (@names) 
    {
        [...]
        processTemplate(
        {
          TEMPLATE_PATH => "/etc/myservice/user.conf",
          OUTPUT_FILENAME => "/etc/myservice/$name.conf"
        );
        [...]
    }

bq. Content is available under GNU Free Documentation License 1.3 unless
otherwise noted. Original document from: http://wiki.contribs.org/
