<?php
class UserController extends ss_Controller
{	
	public $user;
	
	public function init() 
	{
		parent::init();
		$this->user = new Default_Model_User();
		$this->view->user = $this->user;		
	}
	public function alterAction()
	{
		$request = $this->_getParam('user');
		$form = $this->user->getForm(false);
		$form->setPostAction($request['action']);	
		if($form->isValid($request)) {
			$arr = $form->getValues();
			$this->user->mapProperties($arr['user']);
			$this->user->save();
			if(isset($this->session->userForm)) {
				unset($this->session->userForm);
			}
			$this->view->user = $this->user;
			$this->redirector->gotoSimpleAndExit('view', 'user', 'default', array('id' => $this->user->id));
		}
		else {			
			$this->session->userForm = $request;
			$this->redirector->gotoSimpleAndExit($request['action']);			
		}
	}
	public function deleteAction()
	{
		$this->user->id = $this->_getParam('id');
		$this->user->delete();
	}
	public function viewAction()
	{
		$id = $this->_getParam('id');
		$this->user->find($id);				
	}
	public function newAction()
	{
		$form = $this->user->getForm();
		$form->setPostAction('new');		
		if(isset($this->session->userForm)) {
			$form->getElement('token')->removeValidator('FormToken');
			$form->isValid($this->session->userForm);
			unset($this->session->userForm);
		}	    	    
		$form->setAction($this->_helper->url->simple('alter'));
	    $this->view->form = $form;
	}
	public function editAction()
	{
		$this->user->find($this->_getParam('id'));
		$form = $this->user->getForm();		
		$form->setPostAction('edit');
		if(isset($this->session->userForm)) {
			$form->getElement('token')->removeValidator('FormToken');
			$form->isValid($this->session->userForm);
			unset($this->session->userForm);
		}	
	    $form->setAction($this->_helper->url->simple('alter'));
	    $this->view->form = $form;
	}
    public function indexAction()
    {
    	$this->view->paginator = $this->user->getPaginator();
    	$this->view->paginator->setItemCountPerPage(10);
    	$this->view->paginator->setCurrentPageNumber(1);
    	Zend_Paginator::setDefaultScrollingStyle('Sliding');
		Zend_View_Helper_PaginationControl::setDefaultViewPartial(
    		'ss_Pagination.phtml'
		);
		$this->view->paginator->setCurrentPageNumber($this->_getParam('page'));
		$this->view->paginator->setView($this->view);
    }

}