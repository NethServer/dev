======================
Creating web UI module
======================

In this page you can find a working example of a simple UI for a new
module, but, first a little of theory.

Web UI structure
================

All code is organized in three main directories:

*  ``/usr/share/nethesis/Nethgui``: framework libraries (can be used for
   other projects)
*  ``/usr/share/nethesis/NethServer``: actual implementation of modules UI
*  ``/usr/share/nethesis/nethserver-manager``: web root directory

Nethgui is a MVC framework that aims to abstract the developer from
the backend and frontend. This means that you don’t have to deal with
reading and writing properties from DB, neither care about HTML, CSS and
JavaScript on the client side. You just write the controller.
Of course, if you want, you can play with all three layers but it
shouldn’t be necessary in the most of cases.

Each module is composed by 4 parts:

* Controller: ``/usr/share/nethesis/NethServer/Module/.php``
* View: ``/usr/share/nethesis/NethServer/Template/.php``
* Translation: ``/usr/share/nethesis/NethServer/Language//NethServer\_Module*.php``
* Inline help : ``/usr/share/nethesis/NethServer/Help/NethServer_Module*\ .html``

If needed, a module can add extra resources:

* Specific authorization (JSON format): ``/usr/share/nethesis/NethServer/Authorization/.json`` - See Nethgui:Authorization
* Custom CSS: ``/usr/share/nethesis/NethServer/Css/.css`` - See Including CSS
* ``Custom JavaScript: /usr/share/nethesis/NethServer/Js/.js`` - See Including JS
* Unit tests: ``/usr/share/nethesis/NethServer/Test/Unit/NethServer/Module/.php`` - See Nethgui unit test
* Utility libraries: ``/usr/share/nethesis/NethServer/Tool/.php``

Writing the code
================

We add a UI to the package *nethserver-ejabberd* module. The UI will
expose 2 properties of the ``ejabberd`` db key.

Properties:

* **status**: start and stop the ejabberd daemon on boot, can be  *enabled* or *disabled*
* **WelcomeText**: welcome text, can be anything

Controller
----------

First, we create the controller which has 3 main functions:

* **initializeAttributes**: handle module position in menu
* **initialize**: bind the properties to the database and set the validator
* **onParametersSaved**: apply the configuration

Here is the controller
(``/usr/share/nethesis/NethServer/Module/Ejabber.php``):

.. code-block:: php

     class Ejabber extends \Nethgui\Controller\AbstractController   
     {
          // Add the module under the 'Configuration' section, 
          protected function initializeAttributes(\Nethgui\Module\ModuleAttributesInterface $base){
             return \Nethgui\Module\SimpleModuleAttributesProvider::extendModuleAttributes($base, 'Configuration', 30);
         }
              // Declare all parameters
         public function initialize(){
                  parent::initialize();
                 // Bind 'WelcomeText' view parameter to 'WelcomeText' prop in ejabberd key of configuration db
                 $this->declareParameter('WelcomeText', Validate::ANYTHING, array('configuration', 'ejabberd', 'WelcomeText'));
         }

             // Execute actions when saving parameters
         protected function onParametersSaved($changes) {
             // Signal nethserver-ejabberd-save event after saving props to db
             $this->getPlatform()->signalEvent('nethserver-ejabberd-save@post-process');
         }
      }


View
----

Show all fields using built-in functions.
If needed, you can add extra HTML markup but remember that the output
must be functional on any device (desktop, mobile, text browser, etc).

Template (`/usr/share/nethesis/NethServer/Template/Ejabber.php`):

.. code-block:: php

    echo $view->header()->setAttribute('template', $T('Ejabber_Title'));

    // add simple panel
    echo $view->panel()
        //add 'status' parameter checkbox with value when checked and unchecked
        ->insert($view->checkbox('status', 'enabled')->setAttribute('uncheckedValue', 'disabled'));
        //add 'WelcomeText' text input field
    echo $view->panel()->insert($view->textInput('WelcomeText'));
    ;

    // show submit and help buttons
    echo $view->buttonList($view::BUTTON_SUBMIT | $view::BUTTON_HELP);

Translation
-----------

Translation files, are simple PHP files containing an associative
array.
All module language files are placed in ``/usr/share/nethesis/NethServer/Language/<lang>``.
Given a module with name "Test", the english language file will be ``/usr/share/nethesis/NethServer/Language/en/NethServer_Module_Test.php``.

Warning messages about missing translations can be found in ``/var/log/messages`` after Nethgui debug is enabled.
To enable the debug, use index_dev.php on urls, eg: ``https://<ipaddress>/index_dev.php/en/<module>``.

English translation
(`/usr/share/nethesis/NethServer/Language/en/NethServer_Module_Ejabber.php)`:

::

  <?php

  $L['Ejabber_Title'] = 'Chat server';
  $L['status_label'] = 'Enable Ejabber chat server';
  $L['WelcomeText'] = 'Welcome!';

Inline help
-----------

Help pages are RST documents compiled into xHTML pages at package build time.

::

 ===========
 Chat server
 ===========

 Ejabber is a chat server that implements the Jabber/XMPP protocol Jabber / XMPP, it support TLS on standard XMPP ports (5222 or 5223).

 The chat server uses system users to login.
            
        

More examples
=============

More examples can be found `here <https://github.com/nethesis/nethserver-ui-examples>`_ or
browsing the `existing modules <https://github.com/nethesis/nethserver-base/tree/master/root/usr/share/nethesis/NethServer/Module>`_.
