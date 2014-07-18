<?php
class Default_Form_Algorithm extends ss_Form 
{
	public $elements = array (
		'name' => array(
			'name' => 'name',
			'label'=>'Όνομα',
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
				//'StringToLower'
			)
		),
		'body' => array(
			'name' => 'body',
			'label' => 'Κώδικας',
			'allowEmpty' => true,
			'type'=> 'text',					
			'required' => false,
			'length' => 50,
		),
		'inputFile' => array(
			'name' => 'inputFile',
			'label' => 'Αρχείο Εισόδου',
			'allowEmpty' => true,
			'type'=> 'text',					
			'required' => false,
			'length' => 50,
		),
		'notes' => array(
			'name' => 'notes',
			'label' => 'Σημειώσεις',
			'allowEmpty' => true,
			'type'=> 'text',					
			'required' => false,
			'length' => 50,
		)
	);
}