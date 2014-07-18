<?php

class LoginController extends ss_Controller
{
	public $form;

    public function init()
    {
    	parent::init();
    	$action = $this->_helper->url->simple('auth');
    	$this->form = new Default_Form_Login(array(
    		'action' => $action)
    	);
    }

    public function indexAction()
    {
    	if(!Zend_Auth::getInstance()->hasIdentity()) {
	    	if($this->session->loginError) {
	    		$this->form->setDescription($this->session->loginError);
	    		$this->view->error = $this->session->loginError;
	    		unset($this->session->loginError);
	    	}
	    	$this->view->form = $this->form;
    	}
    }
    public function logoutAction()
    {
    	Zend_Auth::getInstance()->clearIdentity();
    	Zend_Session::destroy(true);
    	$this->redirector->gotoSimpleAndExit('index');
    }
    
    public function authAction()
    {
    	$auth = Zend_Auth::getInstance();
    	$authAdapter = new Zend_Auth_Adapter_DbTable(
    		Zend_Registry::get('db'),'users','username','password', 'MD5(?)'
    	);
    	$authAdapter->setIdentity($this->_getParam('username'))->setCredential($this->_getParam('password'));
    	$result = $auth->authenticate($authAdapter);
 		if($result->getCode() == Zend_Auth_Result::SUCCESS) {
 			$this->session->authUser = new Default_Model_User();
 			$this->session->authUser->mapProperties((array)$authAdapter->getResultRowObject(null, array('password')));
 			$this->view->authUser = $this->session->authUser;		 	
 		}
 		else {
 			$this->session->loginError = __('loginError');
 		}
 		$this->redirector->gotoSimpleAndExit('index');
    }
}

