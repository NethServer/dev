======================
HA (High Availability)
======================

This service is packaged inside ``nethserver-ha`` RPM.

The only supported scenario is a two node cluster in active-passive mode.

This package configures:

* a DRBD storage in Primary/Secondary mode, the block device is formatted using ext4 
  and is mounted only on master node
* Corosync and pacemaker
* A virtual IP on green interface

Architecture
============

Components:

* clustering is done using pacemaker and corosync
* configuration tools are ``pcs`` and ``ccs``
* service data are stored inside a DRBD storage
  
Constraints
===========

* DRBD resource is named ``drbd00``
* System names are fixed: ns1 for primary node, ns2 for secondary node

Database
========

The ``ha`` key is saved inside the ``configuration`` database and should be
the same on both nodes.

Available options:

* ``ClusterName``: cluster name used for Corosync, if blank a hash of virtual the virtual IP will be used
* ``DrbdDisk``: device where DRBD is stored, default is ``/dev/VolGroup/lv_drbd``
* ``VirtualIP``: virtual ip for clustered services
* ``VirtualMask``: virtual netmask for clustered services, default is ``255.255.255.0``


STONITH and resource fencing
============================

The cluster mys t be configured for both STONITH and resource fencing.
Resource fencing is already configured at DRBD level using Corosync Redundant Ring Protocol.

STONITH fencing must be set using ``pcs`` command line tool.

