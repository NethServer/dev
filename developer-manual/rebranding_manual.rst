===============================
Rebranding Administrator Manual
===============================

It's possible to create a custom version of the Administrator Manual.

Environment
===========

1. Clone the documentation repository 

2. Create a directory inside the main :file:`administrator-manual/<lang>` directory. 
   Example for a new rebranding called NethService and available only in Italian:

   .. code:: 
     
     mkdir administrator-manual/it/nethservice

3. Enter the directory, and create the structure:
   
   .. code:: 
 
     cd nethservice
     mkdir _templates _static _build _themes

4. Copy the makefile and configuration from parent directory:

   .. code:: 
 
     cp ../Makefile ../conf.py .

Contents
========

First, create a custom :file:`index.rst` with required chapters. Example: ::

 My section
 -------------
   
 .. toctree::
       :maxdepth: 2

    installation
    newchapter


To add a chapter, create new rst file inside the current directory. Example for :file:`newchapter.rst`: ::

 ===========
 New chapter
 ===========

 This is a new chapter.

If you wish to reuse existing chapters, create links to the parent directory. Example: ::

 ln -s ../installation.rst installation.rst

Product name and version
========================

Edit the :file:`conf.py` by setting product name and version. Feel free to customize anything you need but make sure to edit at least following variables:

* project
* release

Create a :file:`rst_prolog` file with the macro for product name and download site. Content of :file:`rst_prolog` file: ::

 .. |product| replace:: NethService
 .. |download_site| replace:: http://www.nethesis.it

Theme
=====

Choose and existing Sphinx theme or copy a new theme inside the :file:`_themes` directory.
If you want to use a custom theme, remember to set following variables inside :file:`conf.py`: ::

 html_theme_path = ['_themes']
 html_theme = 'mynewshinytheme'

Artworks
========

If you wish to add custom artworks like logo and favicon, edit these variables inside :file:`conf.py`: ::
 
 html_static_path = ['_static']
 html_logo = '_static/logo.png'
 html_favicon = '_static/favicon.ico
