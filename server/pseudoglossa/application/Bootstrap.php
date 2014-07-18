<?php
class Bootstrap extends Zend_Application_Bootstrap_Bootstrap
{
	protected function _initView()
	{
		$view = new Zend_View();
		$view->doctype('XHTML1_STRICT');
		$view->setEncoding('utf-8');
		$view->headTitle('On-line διερμηνευτής για την Ψευδογλώσσα της ΑΕΠΠ');
		$view->headMeta()->appendHttpEquiv('Content-Type','text/html; charset=UTF-8')
		      ->appendHttpEquiv('Content-Language', 'el-GR');
		
		//cache control
		/*$view->headMeta()->appendHttpEquiv('expires','Thu, 16 Mar 2000 11:00:00 GMT')
		->appendHttpEquiv('pragma','no-cache')
		->appendHttpEquiv('Cache-Control','no-store, no-cache, must-revalidate, private, post-check=0, pre-check=0, max-stale=0');
		*/
		$view->headMeta()->appendHttpEquiv('keywords', 'εκτέλεση, αλγόριθμος, ψευδογλώσσα, γλώσσα, ΑΕΠΠ, Α.Ε.Π.Π., προγραμματισμός');

		$viewRenderer = Zend_Controller_Action_HelperBroker::getStaticHelper('ViewRenderer');
		$viewRenderer->setView($view);
		return $view;
	}
	protected function _initModules()
	{
		$front = Zend_Controller_Front::getInstance();
		$front->addModuleDirectory(APPLICATION_PATH . DIRECTORY_SEPARATOR . 'modules');
		$front->throwExceptions(true);
		$front->setParam('useDefaultControllerAlways', false);		
	}
	protected function _initTopLevel()
	{
		include_once('topLevel.php');
	}
	protected function _initLanguage()
	{
		$this->bootstrap('ssLoader');
		$options = $this->getOption('resources');
		$lang = $options['locale']['language'];
		include_once('language'.DIRECTORY_SEPARATOR.$lang.DIRECTORY_SEPARATOR.'lang.php');
	}
	protected function _initSession()
	{
		$this->bootstrap('db');
		$options = $this->getOption('resources');
		$config = $options['session']['db'];
		Zend_Session::setOptions(array('cookie_lifetime' => 648000));		
		Zend_Session::start(array(
			'name' => 'pseudoglossaId',			
		));
		$session = new Zend_Session_Namespace('default');
		if(!$session->isUserLogged) {
			$session->isUserLogged = false;
		}
		Zend_Registry::set('session', $session);
		return $session;
	}
	protected function _initTz()
	{
		 	date_default_timezone_set('Europe/Athens');
	}
	protected function _initDb() 
	{
		$resource = $this->getPluginResource('db');
		$db = $resource->init();
		/*$db->query("SET NAMES 'utf8'");
		$db->query('SET CHARACTER SET utf8');
		*/
		Zend_Registry::set('db', $db);
		return $db;
	}
	protected function _initAutoload()
	{
		$autoloader = new Zend_Application_Module_Autoloader(array(
		    'namespace' => 'Default',
		    'basePath' => dirname(__FILE__).DIRECTORY_SEPARATOR.'modules'.DIRECTORY_SEPARATOR.'default',		
		));
		return $autoloader;
	}	
	protected function _initSsLoader()
	{
		$autoloader = Zend_Loader_Autoloader::getInstance();
		$autoloader->registerNamespace('ss_');
	}
}
