==========================
Creating inline help pages
==========================


The online documentation is written in `RST
format <http://docutils.sourceforge.net/rst.html>`__. Each document is
converted to `XHTML <http://www.w3.org/TR/xhtml1/>`__ at package build
time. After installing a package, the server-manager web application
serves the corresponding XHTML version.

To get a list of help pages visit
``http://<your_server>:980/<lang>/Help``. The page will show a list of
available documents on the left column and a list of templates to
generate a new help page on the right column. You need to create an help
page for each supported language using the template: just copy and paste
the code to the destination file.

All help pages must be saved to the following absolute path: 
``/usr/share/nethesis/NethServer/Help/NethServer_Module_<name>.rst``

Editing rules
=============

To write an online help document, respect the following rules.

* The document must start with a title such as 

::

  ==============
  Document title
  ==============

* If a page is divided in tab, each tab title is in the form:

::

  Tab title
  =========

* Each field must be described as a definition list. The indentation of

::

  My field
       This is my description

* A field description can contain a bullet list:<pre>

::

  My field
      This is my description

      * First element
      * Second element

* If any words needs emphasis, use the asterisk character:

::

    This is my *important* word.

# Actions, usually identified by buttons like *Create* or *Configure*
should be given a separate section. Where two actions have similar
forms, like *Create* and *Modify*, they can be merged together.

::

    Create / Modify
    ---------------

* The *Delete* action should be documented only to clarify its side
   effects.


Creating help for plugin modules
================================

Some NethServer modules have a plugin behavior which means
the module will load all help documents inside a well known directory.
Loaded files will be rendered as parts of the parent document.

Inside the parent document, add an include directive like this:

::

    .. raw:: html

       {{{INCLUDE NethServer_Module_User_Plugin_*.html}}}

When creating inline help for web ui plugin, the following rules
apply:

# do not repeat the name of parent module
# use the ``^`` character for headers
# add this comment at the top of the file

::

    .. --initial-header-level=3

The actual level value depends on the type of plugin. Usually *2* or *3* applies. 
For instance, see ``NethServer_Module_SharedFolder_Plugin_Samba.rst`` inside nethserver-samba package.

Building docs inside RPMS
=========================

RST documentation needs to be compiled in HTML.
To include HTML files inside the RPM, remember to add this macro in the spec file, under the *%build* section: ::

  %{makedocs}

Example: ::

  %build
  ...
  %{makedocs}
  ...
  perl createlinks

RST editors
===========

Here some RST editor with syntax hilighting.

Windows platform:

* http://notepad-plus-plus.org/
* www.geany.org
* http://www.sublimetext.com/ (non-free)

Linux platform:

* vim (of course!)
* gedit

Web:

* http://rst.ninjs.org/
* https://notex.ch/
