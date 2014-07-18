<?php
class ss_Form extends Zend_Form
{
	/* 
	 * member variables should have different names from element names
	 */
	public $tokenValue;
	public $tokenElement;
	public $model;
	public $elements;
	
	public $extraValidators = array();	
	public function setPostAction($action)
	{
		foreach($this->extraValidators[$action] as $name => $value) {
			$el = $this->getElement($name);				
			$el->addValidators($value);			
		}		
		if($action == 'edit') {
			foreach($this->_elements as $k => $v) {
				$v->setValue($this->model->$k);
			}
			$ie = new Zend_Form_Element_Hidden('id');
	    	$ie->setValue($this->model->id);
	    	$this->addElement($ie);
		}		
		$ae = new Zend_Form_Element_Hidden('action');
	    $ae->setValue($action);
	    $this->addElement($ae);
	}
	public function __construct(array $options)
	{
		parent::__construct($options);
		$this->setMethod('POST');
		$this->setIsArray(true);
		$this->tokenValue = microtime(true);
		foreach($this->elements as $name => $options) {			
			$class = 'Zend_Form_Element_' . ucfirst($options['type']);	
			$el = new $class($options);			
			$this->addElement($el);
		}
		$this->tokenElement = new Zend_Form_Element_Hidden('token');
		$this->tokenElement->setAttrib('value', $this->tokenValue);
		$this->tokenElement->addValidator(new ss_Validate_FormToken($formName));
		$this->addElement($this->tokenElement);
		$this->addElement(new Zend_Form_Element_Submit(__('submit')));
		$this->addElement(new Zend_Form_Element_Reset(__('reset')));
	
	}
	public function setModel($model)
	{
		$this->model = $model;		
	}
	public function setToken()
	{
		$session = Zend_Registry::get('session');
		$session->formToken = $this->token;
	}
}