<?php
class ss_Controller_Amf extends Zend_Controller_Action 
{
	public $server;
	
	public function init()
	{
		$this->server = new Zend_Amf_Server();

	}
	public function preDispatch()
	{
		$this->_helper->layout()->disableLayout();
		$this->_helper->viewRenderer->setNoRender(true);		
	}
}