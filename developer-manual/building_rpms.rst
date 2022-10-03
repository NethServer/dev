.. index::
   pair: Build; RPM
   single: Mock

.. _buildrpm-section:

=============
Building RPMs
=============

To build RPMs for NethServer the following methods are provided:

- :ref:`nethserver-makerpms-module` for local builds with Podman [#Podman]_
  and GitHub Actions automated builds

- :ref:`nethserver-mock-module` local build with the Mock [#Mock]_ configuration
  files pointing to NethServer YUM repositories

Both methods allow to build also RPMs from other projects. Check out the documentation carefully.

Development vs Release builds
=============================

A common convention about ``.spec`` files says that the ``Release`` tag has to append
the RPM ``dist`` macro as suffix in a similar way: ::

    Release: 1%{?dist}

In NethServer,

* when the package is built for a release, use the ``dist`` value ``.ns7`` (or ``.ns6``...);

* when the package is compiled for QA/testing, the ``dist`` macro should reference
  the source code git commit hash. For instance, ``dist`` can be set to ``.2.g8f7ddad.ns7``.

This convention ensures that each RPM is unique and it is always possible to reproduce the build
and its history.

In particular, when building for QA/testing, the build methods linked above prepend the
number of commits in the git log history since the last **tagged release commit**,
followed by ``.g``, followed by a short git commit hash reference.
If the last commit in the repo has a release tag, the ``dist`` macro is set to ``.ns7`` instead.

A **tagged release commit** is a git commit with a tag, starting with a digit
and not containing any "-" (minus) symbol.
For instance ``0.1.2r1`` and ``0ok`` are valid release tags, whilst ``v0.1.2``
and ``0.1.2-1`` are not.

The :ref:`releasetag-section` command helps to create a properly tagged
release commit in the RPM source code repository.

Publishing RPMs
===============

Once RPMs are built, they can be uploaded to ``packages.nethserver.org`` with ``sftp``.
Ask on `community.nethserver.org <https://community.nethserver.org>`_ to obtain the SFTP account required for this purpose.

Use the :ref:`uploadrpms-section` command to publish the RPMs
in the current working directory. The command looks like the following ::

  $ uploadrpms username@packages.nethserver.org:nscom/7.8.2003/nethforge-testing *.rpm

Replace ``7.8.2003`` with the correct NS version number. Also replace ``nethforge-testing``
with the target repository name.

As alternative to the above manual procedure, it is possible to run the build on GitHub Actions:
it automatically publishes the RPMs to ``packages.nethserver.org``, too. Refer to
:ref:`nethserver-makerpms-module` documentation.

.. rubric:: References

.. [#Podman] Podman is a daemonless Linux container engine. https://podman.io/
.. [#Mock] Mock is a tool for building packages. http://fedoraproject.org/wiki/Projects/Mock
