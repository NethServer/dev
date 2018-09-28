=========
Dashboard
=========

The dashboard module is the landing page of NethServer Web UI. It aims to give an overview of system status.
Dashboard is fully pluggable and extensible: each NethServer module can add it's own tab or even a widget inside the System status or Applications tab.

There are three default tabs:

* System status
* Services
* Applications

The dashboard module heavily uses Javascript but works correctly even on smartphones.

SystemStatus tab
================

It's the main tab composed by three main submodules:

* System release: show the system release
* Resource usage:

  * system load
  * cpu number
  * uptime
  * physical memory usage statistics
  * virtual memory (swap) usage statistics
  * root partition usage statistics
* Network

  * configuration of each assigned netwok interface (IP address, netmask, etc.)
  * real-time statistics of received and transmitted data
  * host name, domain name, default gateway

This tab can be extended using plugins.

Services tab
============

Service tab lists all system services, including current status (running or stopped), configured status (enabled or disabled) and associated TCP and UDP ports.
This tab cannot be customized.

Applications tab
================

Applications tab lists all installed application with extra information. Each package can create a special PHP class which describes the installed application.

Extending the dashboard
=======================

The dashboard heavily uses Nethgui framework to render all information, so you need a little bit of understanding on how project:Nethgui PHP framework actually works. 
Don't panic!

Nethgui is a MVC framework specially designed for NethServer web UI tasks.
All files are inside ``/usr/share/nethesis/NethServer`` path, with the following sub-paths:

* Module: controller files
* Template: template files
* Language: language files

Application custom widget
-------------------------

This is the simplest widget inside the Applications tab. This kind of widget should be used by all web applications. 
Let see the nethserver-collectd-web example.
The package must include a PHP file inside ``Module/Dashboard/Applications/`` directory. The script will describe a new class which extends the *AbstractModule* class and implements the *ApplicationInterface* interface. A little scary, eh? There is the full example:

.. code-block:: php
 
 <?php
 
 class Collectd extends \Nethgui\Module\AbstractModule implements \NethServer\Module\Dashboard\Interfaces\ApplicationInterface
 {
    public function getName()
    {
        return "Collectd Web";
    }

    public function getInfo() 
    {
         $cweb = $this->getPlatform()->getDatabase('configuration')->getKey('collectd-web');
         $hostname = $this->getPlatform()->getDatabase('configuration')->getType('SystemName');
         $domain = $this->getPlatform()->getDatabase('configuration')->getType('DomainName');
         return array(
            'url' => "http://$hostname.$domain/".$cweb['alias']
         );
    } 
 }

Not so scary :)

Basically, the *ApplicationInterface* requires to implement two simple methods:

* *getName()*: return the name of the application. The name is used to alphabetically sort all the applications inside the Application tab.
* *getInfo()*: return an arbitrary associative array. All <key,value> pairs will be printed inside a little auto-generated widget. If the array contains a key starting with 'url' string, the value of the key will be wrapped inside an ``<a href=''>`` HTML tag.

We can now analyze the above ``getInfo`` function implementation. First we read the ``collectd-web`` key from the ``configuration`` db. All properties are then accessible as an associative array. Then we read the value of the special keys ``SystemName`` and ``DomainName``. Finally we fill the return array with the url where the web application will be accessible.

System status custom widget
---------------------------

Let's take a *SystemRelease* class which add a widget inside the *SystemStatus* tab:

* Controller: ``Module/Dashboard/SystemStatus/SystemRelease.php``
* Template: ``Template/Dashboard/SystemStatus/SystemRelease.php``
* English translation: ``Language/en/NethServer_Module_Dashboard_SystemStatus_SystemRelease.php``
* Italian translation: ``Language/it/NethServer_Module_Dashboard_SystemStatus_SystemRelease.php``

Translation files are simple PHP associative arrays. The language files in the examples are self-explanatory.

You can find all examples inside the nethserver-ui-examples repository.

Controller
^^^^^^^^^^

First of all, let's introduce few keys concepts about HTTP request handling in Nethgui.
When the browser open an URL, for example ``/SystemRelease``, the system will search for a module named *SystemRelease*. If the request contains some query parameters, the server side module will invoke two functions *process()* and *prepareView()*, if no query is specified only the function *prepareView* will be invoked.

The *process* will handle the query and prepare all data for the *prepareView* function.
For example, here is the *process* implementation of a simple *SystemRelease* module:

.. code-block:: php

 <?php
 ...
 public function process()
 {
     $this->release = $this->readRelease();
 }

Simple. The *process* will invoke a private method *readRelease* which reads a file, and save the result on a private attribute. All data are now available and we have to send them back using the *prepareView* function:

.. code-block:: php

 <?php
 ...
 public function prepareView(\Nethgui\View\ViewInterface $view)
 {
    //if no query is specified, make sure to initialize the data
    if (!$this->release) {
        $this->release = $this->readRelease();
    }
    $view['release'] = $this->release;
 }

The *release* attribute is mapped inside the *$view* array, ready to be sent to the client. When the client requests the page for the first time with no query, we need to fill the *release* attribute because the *process* is not previously called. Then all the *$view* data will be used to fill the HTML template.
If the client send a JSON request with a timestamp as a parameter (which is the standard behavior for ajax calls) the module will invoke *process* and *prepareView*, then all data will be formatted in JSON format.

Request examples:

* HTML rendering: ``/Dashboard/SystemStatus/SystemRelease``
* JSON response: ``/Dashboard/SystemStatus/SystemRelease.json``

Finally, if you want to order the widget inside the System Status tab, you should define a variable *$sortId*, like:

.. code-block:: php

 public $sortId = 40;


View
^^^^

It's time to create a simple template to show the data from the controller. Below there's an example using a built-in CSS class.

.. code-block:: php

 <?php
 echo "<div class='dashboard-item'>";
 echo "<dl>";
 echo $view->header()->setAttribute('template',$T('release_title'));
 echo "<dt>".$T('release_label')."</dt><dd>"; echo $view->textLabel('release'); echo "</dd>";
 echo "</dl>";
 echo "</div>";

This is a static template without any use of Javascript.
Inside the template file, you always have access to the *$view* variable where all data are stored by the previous explained *prepareView* function.
There also a very useful function called *$T(...)* used for translations.
The most important part of this examples is the call *$view->textLabel('release')*. This line is an helper which extract the *release* variable from the view an wrap it a span HTML tag identified by an auto-generated class (useful for Javascript processing).

A full example can be found in the nethserver-ui-examples repository under the dashboard directory.

Custom Tab
----------

Any NethServer package can add a custom tab inside the dashboard. To create a new tab you have to write a class extending an existing controller inside the ``/usr/share/nethesis/NethServer/Module/Dashboard`` directory.
See "API":http://dev.nethserver.org/nethgui/Documentation/Api/ for a list of available controllers.

See *mytab* example in nethserver-ui-examples repository for more information.
