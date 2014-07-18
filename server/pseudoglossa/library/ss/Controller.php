<?php
class ss_Controller extends Zend_Controller_Action
{
	public $session;
	public $redirector;
	
    public function init()
    {
    	$this->redirector = $this->_helper->getHelper('redirector');
		$this->session = Zend_Registry::get('session');
		if($this->session->authUser) {
			$this->view->authUser = $this->session->authUser;
		}
		elseif(!stristr(get_class($this), 'login')) {
			$this->redirector->gotoSimpleAndExit('index', 'login');
		}		
    }
}