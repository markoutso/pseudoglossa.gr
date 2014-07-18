<?php
class Default_Model_AlgorithmsUserTags extends ss_Db_Model
{
	public $algorithmId;
	public $userTagId;
	
	public $tableCols = array('algorithmId', 'userTagId');
	
	public function __construct($options = null)
	{
		parent::__construct('Default_Model_Mapper_AlgorithmsUserTags');
		if(null !== $options) {
			$this->setOptions($options);
		}
	}
}