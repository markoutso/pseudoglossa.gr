<?php
class Default_Model_Group extends ss_Db_Model
{
	public $id;
	public $name;
	public $description;
	public $ownerId;
	public $joinPolicy;
	public $visibility;
	public $commentPolicy;
	public $dateRegistered;
	
	public $owner;
	
	public $formElements = array (
		'name' => array(
				'allowEmpty' => false,
				'type'=> 'text',					
				'required' => true,
				'length' => 50,
				'maxlength' => 128,
				'validators' => array(
					'NotEmpty',
					array('Regex', false, array('/[A-Za-zΆ-ώ][A-Za-zΆ-ώ_0-9\-]+$/u')),
					array('StringLength', false, array(6, 128, 'utf-8')),					
    				//array('validator' => 'regex', 'options' => array('/[A-Za-zΆ-ώ][A-Za-zΆ-ώ_0-9]+/u')),
    				//array('validator' => 'stringLength', 'options' => array(4, 64)),
    				//array('validator' => 'NotEmpty'),
				),
				'filters' => array (
					'*' => 'StringTrim'
				)
		)
	);
	public function __construct($options = null)
	{
		parent::__construct('Default_Model_Mapper_Group');
		if(null !== $options) {
			$this->setOptions($options);
		}
	}
}
?>