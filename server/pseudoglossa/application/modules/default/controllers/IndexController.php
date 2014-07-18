<?php

class IndexController extends Zend_Controller_Action
{

    public function init()
    {    	
        /* Initialize action controller here */
    }

    public function indexAction()
    {
    	$this->view->sessionId = Zend_Session::getId();
    	$session = Zend_Registry::get('session');
        // action body
    }
}