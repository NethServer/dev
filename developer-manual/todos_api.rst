.. index::
   pair: TODO; API

========
TODO API
========

The *TODO API* is specific for the Server Manager web application. It
is designed to execute a list of checks and possibly report the
outcome to the admin user.

An RPM can install one or more executable scripts under
:file:`/etc/nethserver/todos.d/`.

* The script must print the results formatted according to JSON
  [#JSON]_ and the following schema: ::

    {
        "text": "free text",
	"icon": "info-circle",
	"action": {
	    "url": "/User",
	    "label": "Link label"
	}
    }

  ``icon`` and ``action`` keys are optional. The only required key is
  ``text``.  The ``url`` value is actually an absolute path to the
  Server Manager module.  Future versions may support real URLs.

* If the script exit code is non-zero, or if the output is not
  correctly JSON-encoded, an error message is sent to the system log.

* The script must be aware of locale settings, as its output is
  displayed on the user's browser [#Gettext]_.

The executable helper :file:`/usr/libexec/nethserver/admin-todos` is
responsible for the invocation of scripts, validation of output and
error reporting.  It is executed by the :file:`AdminTodo` UI module.  

The :file:`AdminTodo` known callers are:

* :guilabel:`Dashboard`
* :guilabel:`Software center`
* :guilabel:`Network`
* :guilabel:`Backup (configuration)`

Translations
============

A TODO script must be locale-aware.  Use the ``gettext`` library for
code internationalization (i18n) and follow guidelines from
:ref:`section-i18n`.

.. rubric:: References

.. [#JSON] JSON (JavaScript Object Notation) is a lightweight
           data-interchange format. http://json.org/
.. [#Gettext] GNU gettext utilities http://www.gnu.org/software/gettext/
	  
	
