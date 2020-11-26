.. index::
   pair: Build; ISO

.. _buildiso-section:

============
Building ISO
============

To create a NethServer ISO on a NethServer system, follow these steps:

1) Install ``nethserver-createiso`` package

2) Make sure mock cache is clean, execute as ``root`` user: ::

     rm -rf /var/cache/mock/nethserver-iso*

3) Log in as a non-privileged user, member of the ``mock`` group

4) Download CentOS minimal ISO

5) Run ``createiso`` command ::

     createiso -n nethserver -v 7.9.2009 -i CentOS-7-x86_64-Minimal-2009.iso
