<?php
class Default_Form_User extends ss_Form 
{
	public $elements = array (
		'username' => array(
			'name' => 'username',
			'label'=>'Όνομα Χρήστη',
			'allowEmpty' => false,
			'type'=> 'text',					
			'required' => true,
			'length' => 50,
			'maxlength' => 64,			
			'validators' => array(
				'NotEmpty',
				array('Regex', false, array('/[A-Za-zΆ-ώ][A-Za-zΆ-ώ_0-9]+$/u')),
				array('StringLength', false, array(4, 64, 'utf-8')),
			),
			'filters' => array (
				'StringTrim', 
				//'StringToLower'
			)
		),
		'firstName' => array(
			'name' => 'firstName',
			'label' => 'Όνομα',
			'allowEmpty' => true,
			'type'=> 'text',					
			'required' => false,
			'length' => 50,
			'maxlength' => 64,
			'filters' => array (
				'StringTrim'
			)
		),
		'lastName' => array(
			'name' => 'lastName',
			'label' => 'Επώνυμο',		
			'allowEmpty' => true,
			'type'=> 'text',					
			'required' => false,
			'length' => 50,
			'maxlength' => 64,
			'filters' => array (
				'StringTrim'
			)
		),
		'email' => array(
			'name' => 'email',
			'label' => 'email',
			'allowEmpty' => false,
			'type'=> 'text',					
			'required' => true,
			'length' => 50,
			'maxlength' => 128,
			'validators' => array(
				'EmailAddress',
			),
			'filters' => array (
				'StringTrim', 
				//'StringToLower'
				//'*' => 'StringTrim'
			)
		),
		'password' => array (
			'name'=>'password',
			'label'=>'Συνθηματικό',
			'allowEmpty' => false,
			'type'=>'password',
			'required'=>true,
			'length'=>50,
			'maxlength'=>128,
			'validators' => array (
				array('StringLength', false, array(6, 64, 'utf-8'))
			),
			'filters' => array (
				'StringTrim')
		),
	);
	public $extraValidators = array(
		'new' => array(
			'username' => array(
				array('Db_NoRecordExists', false, array('users','username'))	
			),
			'email' => array(
				array('Db_NoRecordExists', false, array('users','email'))
			)
		)
	);
}