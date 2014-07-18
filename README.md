# pseudoglossa.gr

pseudoglossa.gr is an educational, cloud based, interpreter and ide for a simple pseudocode-like programming language used in greek schools.

pseudoglossa.gr is in production mode during the last 6 years and is being successfully used by thousands of greek teachers and students in secondary and undergraduate college education.

## Development status
pseudoglossa.gr is a pet project developed without funding (mostly as a proof of concept) in order to facilitate learning (both of the developer and the users) and is considered experimental. 

## Architecture
pseudoglossa.gr consists of a client application written in actionscript 3 and a backend in php 5. Those two components communicate with [Zend_Amf].

## Dependencies
  - [Adobe Flex Framework] version 3.6a
  - [Zend Framework] version 1
  - [Flight Framework]
  - [swfobject]
  - [DejaVu] monospaced fonts
  - [undo-textfields]
  - [Tango] project icons

## Build instructions
  - Edit src/pseudoglossa/EnvSettings.as and provide the server url of the server/pseudoglossa.gr/amf.php .
  - Edit outputFolderLocation and rootURL compiler options in .actionScriptProperties.
  - Edit projectDescription -> linkedResources -> link -> location in .project and provide the build output folder.
  - Building the project should generate a Pseudoglossa.swf file under the bin-debug folder defined in the previou step.

## Database installation
  - Use server/schema.sql and create a new mysql database.

## Server installation
  - Download and install [Zend Framework]
  - Put folder server/pseudoglossa.gr in a path accessible by the web server
  - Put Pseudoglossa.swf inside pseudoglossa.gr/swf/
  - Copy server/pseudoglossa folder in the filesystem of the server and point APPLICATION_PATH in pseudoglossa.gr/common.php in that folder. Alter include_path in order to load Zend_Framework if needed.
  - Edit server/pseudoglossa/application/configs/application.ini and provide the correct settings.	
  - Point your browser in server url of file server/pseudoglossa.gr/index.php. The swf file should load. Try to create a new account in order to test the functionality of the server.
  
## License
  - pseudoglossa.gr is distributed under the GPLv3. 
  
[Zend_Amf]: http://framework.zend.com/manual/1.10/en/zend.amf.html
[Adobe Flex Framework]: http://sourceforge.net/adobe/flexsdk/wiki/Download%20Flex%203/
[Zend Framework]: http://framework.zend.com/blog/zend-framework-1-12-7-released.html
[Flight Framework]:https://code.google.com/p/flight-framework/
[swfobject]:https://code.google.com/p/swfobject/
[DejaVu]: http://dejavu-fonts.org
[undo-textfields]: https://code.google.com/p/undo-textfields/
[Tango]: http://tango.freedesktop.org/

