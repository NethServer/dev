==============
Package groups
==============

The :guilabel:`Software center` page in the Server Manager displays the YUM
groups (comps) metadata. This is an XML file added to a YUM repository metadata
which describes the packages groups and categories composition.

Submit a change proposal
========================

To modify how groups and categories are displayed in the :guilabel:`Software
center` page a GitHub account is required.

1. edit (on the GitHub web interface) an ``.xml.in`` file
  
  * https://github.com/NethServer/comps/blob/master/nethforge-groups.xml.in
  
  * https://github.com/NethServer/comps/blob/master/nethserver-groups.xml.in

2. open a *pull request*

How to edit ``.xml.in`` files
=============================

Information about :file:`*.xml.in` files is available here:

* about the workflow, see the repository `README <https://github.com/NethServer/comps/blob/master/README.rst>`_
* about the file format and the comps XML structure, see the `Fedora Project Wiki <https://fedoraproject.org/wiki/How_to_use_and_edit_comps.xml_for_package_groups#Comps_structure>`_


