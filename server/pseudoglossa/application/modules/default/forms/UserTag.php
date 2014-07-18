<?php
class Default_Form_UserTag extends ss_Form 
{
	public $elements = array (
		'name' => array(
			'name' => 'name',
			'title' => 'Όνομα',			
			'allowEmpty' => false,
			'type'=> 'text',					
			'required' => true,
			'length' => 50,
			'maxlength' => 255,			
			'validators' => array(
				'NotEmpty',
			),
			'filters' => array (
				'StringTrim', 
			)
		)
	);
}