<?php

class AlgorithmController extends Zend_Controller_Action
{
	public $algorithm;

    public function init()
    {
    	parent::init();
		$this->algorithm = new Default_Model_Algorithm();
		$this->view->algorithm = $this->algorithm;	
    }

    public function indexAction()
    {
        $user = $this->session->user;
    }


}

