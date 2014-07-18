<?php
class Default_Form_Login extends Zend_Form
{
	public $username;
	public $password;
	public function __construct($options)
	{
		parent::__construct(array(
    		'name' => 'login',
    		'method' => 'post'
    	));	
		parent::setOptions($options);
		$this->username = new Zend_Form_Element_Text('username', array(
    		'filters'    => array('StringTrim', 'StringToLower'),
			'required'   => true,
    	));
    	$this->username->setLabel(__('username'));
    	$this->password = new Zend_Form_Element_Password('password', array(
    		'filters'    => array('StringTrim'),
			'required' => true
    	));    	
		$this->password->setLabel(__('password'));	
		$this->addElement($this->username);
		$this->addElement($this->password);
		$this->addElement(new Zend_Form_Element_Submit(__('login')));
	}
}