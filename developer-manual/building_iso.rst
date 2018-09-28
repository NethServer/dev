.. index::
   pair: Build; ISO

.. _buildiso-section:

============
Building ISO
============

To create a NethServer ISO on a NethServer system, follow these steps:

1) Install ``nethserver-createiso`` package

2) Log in as a non-privileged user, member of the ``mock`` group
   
3) Download CentOS minimal ISO
   
4) Run ``createiso`` command ::

     createiso  -i CentOS-7.2.1511-x86_64-minimal.iso -n nethserver -v 7.2.1511-beta1



