.. index::
   pair: Build; RPM
   single: Mock

.. _buildrpm-section:

=============
Building RPMs
=============

To build NethServer RPMs a few methods are provided:
 - ``travis-ci.org`` automated build with a ``.travis.yml`` file inside each repository
 - ``nethserver-mock`` with the Mock [#Mock]_ configuration files pointing to NethServer YUM repositories

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

The build environment supports the following variable:

- ``NSVER``
- ``DOCKER_IMAGE``
- ``DEST_ID``

NSVER
~~~~~

Select the target NethServer version for the build system.
Currently the only supported value is ``7``.

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

nethserver-mock
===============

The ``nethserver-mock`` package provides some scripts to ease the process of
building and releasing RPMs.

Configuring the environment
---------------------------

On **NethServer**, install ``nethserver-mock`` package, by typing: ::

  yum install nethserver-mock

On **Fedora**, and other RPM-based distros run the command: ::

  yum localinstall <URL>

Or ::

  dnf install <URL>

where <URL> is http://packages.nethserver.org/nethserver/7.3.1611/base/x86_64/Packages/nethserver-mock-1.3.2-1.ns7.noarch.rpm at the time of writing.
The build process uses Mock and must be run as a non privileged user,
member of the ``mock`` system group.  Add your user to the ``mock``
group: ::

  usermod -a -G mock <username>

Running the scripts
-------------------

The ``make-rpms`` command eases building of the NethServer RPMs by
hiding the complexity of other commands.  It is designed to work
inside the git repository directory of NethServer packages, but should
fit other environments, too.

Start by cloning the git repository and move inside it. For instance ::

  git clone https://github.com/nethesis/nethserver-mail-server.git
  cd nethserver-mail-server

To build the RPM just type ::

  make-rpms nethserver-mail-server.spec

The command writes the results into the current directory, assuming
every change to the source code has been commited. If everything goes
well they consist of:

* source RPM
* binary/noarch RPMs
* mock log files

To clean up the git repository directory, ``git clean`` may help: ::

  git clean -x -n

Substitute ``-n`` with ``-f`` to actually remove the files!

.. note::

   The ``make-rpms`` command is sensible to ``dist`` and ``mockcfg``
   environment variables.  If they are missing the default values are
   shown by invoking it without arguments.

For example: ::

  dist=ns7 mockcfg=nethserver-7-x86_64 make-rpms *.spec

The ``make-rpms`` command in turn relies on other scripts

``make-srpm``
  Builds the :file:`.src.rpm` file.

``prep-sources``
  Extracts and/or fetches the source tarballs.

The first ``Source`` tag in the :file:`.spec` file is assumed refer to
the local git repository.  If an absolute URL is specified, only the
last part is considered. Other ``SourceN`` tags must conform to the
Fedora RPM guidelines [#FedoraPG]_. The external sources are actually
fetched by the ``spectool`` command.

If the file :file:`SHA1SUM` exists in the same directory of the
:file:`.spec` file the tarballs are checked against it.

Development and Release builds
------------------------------

During the development, a package can be rebuilt frequently:
incrementing build numbers and unique release identifiers are useful
during this stage to help the whole process.

When ``make-rpms`` is invoked, it checks the git log history and tags
to decide what kind of build is required: *development* or *release*.

Release builds produce a traditional RPM file name, i.e.: ::

  nethserver-mail-server-1.8.4-1.ns6.noarch.rpm

Development builds produces a *marked* RPM, i.e: ::

  nethserver-mail-server-1.8.3-1.6gite86697e.ns6.noarch.rpm

Other differences in *development* from *release* are

* the ``%changelog`` section in :file:`.spec` is replaced by the git
  log history since the last tag

* the number of commits since the last tag, and the latest git commit
  hash are extracted from ``git describe`` and prepended to the
  ``%dist`` macro.

Signing RPMs
------------

The command ``sign-rpms`` is a wrapper around ``rpm --resign``
command.  Its advantage is it can read a password for the GPG
signature from the filesystem. Sample invocation::

   sign-rpms -f ~/.secret -k ABCDABCD

The signature is added automatically by ``packages.nethserver.org``.

Creating a release tag
======================

The :command:`release-tag` command, provided by the ``nethserver-mock`` RPM, executes the following workflow:

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


The :command:`release-tag` command is now ready for use. This is the help output::

  release-tag -h
  Usage: release-tag [-h] [-k KEYID] [-T <x.y.z>] [<file>.spec]

Sample invocation: ::

  release-tag -k ABCDABCD -T 1.8.5 nethserver-mail-server.spec

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

.. [#Mock] Mock is a tool for building packages. http://fedoraproject.org/wiki/Projects/Mock
.. [#FedoraPG] Referencing Source http://fedoraproject.org/wiki/Packaging:SourceURL
.. [#Autobuild] Is a particular kind of repository in ``packages.nethserver.org`` that hosts the rpms builded automatically from travis-ci.org. http://packages.nethserver.org/nethserver/7.4.1708/autobuild/x86_64/Packages/
.. [#Testing] Is a repository in ``packages.nethserver.org`` that hosts the rpms builded automatically from travis-ci.org started form official ``nethserver`` github repository. http://packages.nethserver.org/nethserver/7.4.1708/testing/x86_64/Packages/
.. [#NethBot] Is our bot that comments the issues and pull request with the list of automated RPMs builds. https://github.com/nethbot
