.. index::
   pair: Build; RPM
   single: Mock

.. _buildrpm-section:

=============
Building RPMs
=============

To build NethServer RPMs the following methods are provided:

 - ``travis-ci.org`` automated build with a ``.travis.yml`` file inside each repository

 - ``nethserver-makerpms`` local build with Podman [#Podman]_

 - ``nethserver-mock`` local build with the Mock [#Mock]_ configuration files pointing to NethServer YUM repositories

travis-ci.org
=============

`travis-ci.org <https://travis-ci.org>`_ automatically builds RPMs and uploads
them to ``packages.nethserver.org``.

Configuration
-------------

To automate the RPM build process using Travis CI

* create a ``.travis.yml`` file inside the source code repository hosted on
  GitHub

* the `NethServer repository <https://travis-ci.org/NethServer/>`_ must
  have Travis CI builds enabled

The list of enabled repositories is available at `NethServer page on
travis-ci.org <https://travis-ci.org/NethServer/>`_.

This is an example of ``.travis.yml`` contents: ::

  ---
  language: ruby
  services:
      - docker
  branches:
      only:
          - master
  env:
    global:
      - DEST_ID=core
      - NSVER=7
      - DOCKER_IMAGE=nethserver/makerpms:${NSVER}
      - >
          EVARS="
          -e DEST_ID
          -e TRAVIS_BRANCH
          -e TRAVIS_BUILD_ID
          -e TRAVIS_PULL_REQUEST_BRANCH
          -e TRAVIS_PULL_REQUEST
          -e TRAVIS_REPO_SLUG
          -e TRAVIS_TAG
          -e NSVER
          -e ENDPOINTS_PACK
          "
  script: >
      docker run -ti --name makerpms ${EVARS}
      --hostname b${TRAVIS_BUILD_NUMBER}.nethserver.org
      --volume $PWD:/srv/makerpms/src:ro ${DOCKER_IMAGE} makerpms-travis -s *.spec
      && docker commit makerpms nethserver/build
      && docker run -ti ${EVARS}
      -e SECRET
      -e SECRET_URL
      -e AUTOBUILD_SECRET
      -e AUTOBUILD_SECRET_URL
      nethserver/build uploadrpms-travis

Usage
-----

Travis CI builds are triggered automatically when:

* one or more commits are pushed to the `master` branch of the NethServer repository, as
  stated in the ``.travis.yml`` file above by the ``branches`` key

* A *pull request* is opened from a NethServer repository fork or it is updated
  by submitting new commits

After a successful build, the RPM is uploaded to ``packages.nethserver.org``,
according to the ``DEST_ID`` variable value. Supported values are ``core`` for
NethServer core packages, and ``forge`` for NethForge packages.

Pull requests are commented automatically by ``nethbot``
[#NethBot]_ with the links to available RPMs.

Also issues are commented by ``nethbot`` if the following rules are respected in git commit messages:

1. The issue reference (e.g. ``NethServer/dev#1234``) is present in the merge
   commit of pull requests

2. The issue reference is added to standalone commits (should be rarely used)


Global variables
^^^^^^^^^^^^^^^^

The build environment supports the following variables:

- ``NSVER``
- ``DOCKER_IMAGE``
- ``DEST_ID``

NSVER
~~~~~

``NSVER`` selects the target NethServer version for the build system. Currently
the supported version values are ``7`` and ``6``.

DOCKER_IMAGE
~~~~~~~~~~~~

The Docker build image can contain different RPMs depending on the tag:

- ``latest`` or ``7``: contains only dependencies to build ``nethserver-*`` RPMS, like ``nethserver-base``.
  It actually installs only nethserver-devtools and a basic RPM build environment without gcc compiler.
- ``buildsys7``: it s based on the previous environment. It also pulls in the dependencies for arch-dependant packages (like ``asterisk13`` or ``ns-samba``).
  It actually installs the ``buildsys-build`` package group, which provides the ``gcc`` compiler among other packages.

DEST_ID
~~~~~~~

If ``DEST_ID=core``:

* Builds triggered by pull requests are uploaded to the ``autobuild`` [#Autobuild]_ repository

* Builds triggered by commits pushed to master are uploaded to the ``testing``
  [#Testing]_ repository. If a git tag is on the last available commit,
  the upload destination is the ``updates`` repository.

If ``DEST_ID=forge``:

* Pull requests are uploaded to ``nethforge-autobuild``

* Branch builds are uploaded to ``nethforge-testing``, whilst tagged builds are uploaded to ``nethforge``


.. index::
   pair: Sign; RPM

.. _rpm_prepare_env:

nethserver-makerpms
===================

This local build method runs on Fedora 29+ and NethServer 7. See
:ref:`nethserver-makerpms-module` for more information.

nethserver-mock
===============

This local build method runs on any Fedora version and NethServer 7. See
:ref:`nethserver-mock-module` for more information.



Creating a release tag
======================

The :command:`releasetag` command, provided by the ``nethserver-makerpms`` RPM
or its equivalent :command:`release-tag`, provided by the ``nethserver-mock``
RPM, executes the following workflow:

* reads the git log history and fetches related issues from the issue
  tracker web site.
* updates the ``%changelog`` section in the :file:`spec` file.
* commits changes to the :file:`spec` file.
* tags the commit (with optional GPG signature).

To fetch issues from private GitHub repositories
`create a private GitHub access token <https://github.com/settings/tokens/new>`_.
Select the ``repo`` scope only.

Copy it to :file:`~/.release_tag_token` and keep its content secret: ::

  chmod 600  ~/.release_tag_token

.. tip::

    The private access token is useful also for public repositories
    because authenticated requests have an higher API rate limit


The :command:`releasetag` command is now ready for use. This is the help output::

  releasetag -h
  Usage: releasetag [-h] [-k KEYID] [-T <x.y.z>] [<file>.spec]

Sample invocation: ::

  releasetag -k ABCDABCD -T 1.8.5 nethserver-mail-server.spec

Replace ``ABCDABCD`` with your signing GPG key. The ``$EDITOR``
program (or git ``core.editor``) is opened automatically to adjust the
commit message. The same text is used as tag annotation.
Usage of ``-k`` option is optional.

The :file:`.spec` argument is optional: if not provided the first
:file:`.spec` file in the current directory is processed.

To push the tagged release to GitHub (and possibly trigger an automated build)
ensure to add the ``--follow-tags`` option to ``git push`` invocation. For
instance: ::

  git push --follow-tags

To make ``--follow-tags`` permanent run this command: ::
  
  git config --global push.followTags true

.. rubric:: References

.. [#Podman] Podman is a daemonless Linux container engine. https://podman.io/
.. [#Mock] Mock is a tool for building packages. http://fedoraproject.org/wiki/Projects/Mock
.. [#Autobuild] Is a particular kind of repository in ``packages.nethserver.org`` that hosts the rpms builded automatically from travis-ci.org. http://packages.nethserver.org/nethserver/7.4.1708/autobuild/x86_64/Packages/
.. [#Testing] Is a repository in ``packages.nethserver.org`` that hosts the rpms builded automatically from travis-ci.org started form official ``nethserver`` github repository. http://packages.nethserver.org/nethserver/7.4.1708/testing/x86_64/Packages/
.. [#NethBot] Is our bot that comments the issues and pull request with the list of automated RPMs builds. https://github.com/nethbot
