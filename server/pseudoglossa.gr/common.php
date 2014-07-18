<?php

// Define path to application directory
defined('APPLICATION_PATH')
    || define('APPLICATION_PATH', realpath(dirname(__FILE__) . '/../pseudoglossa/application'));

$env = stristr($_SERVER['HTTP_HOST'], 'localhost') ? 'development' : 'staging';
// Define application environment
defined('APPLICATION_ENV')
    || define('APPLICATION_ENV', (getenv('APPLICATION_ENV') ? getenv('APPLICATION_ENV') : $env));

// Ensure library/ is on include_path

set_include_path(implode(PATH_SEPARATOR, array(
    realpath(APPLICATION_PATH . '/../library'),
    get_include_path(),
)));


/*
if($env == 'staging') {
	set_include_path(implode(PATH_SEPARATOR, array(
    	get_include_path(),
    	'local path to zf'
	)));
} 
*/
require_once 'Zend/Application.php';  
// Create application, bootstrap, and run
