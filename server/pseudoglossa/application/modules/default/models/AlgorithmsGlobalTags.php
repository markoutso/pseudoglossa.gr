<?php
class Default_Model_AlgorithmsGlobalTags extends ss_Db_Model
{
	public $algorithmId;
	public $globalTagId;
		
	public $tableCols = array('algorithmId', 'globalTagId');
	
	public function __construct($options = null)
	{
		parent::__construct('Default_Model_Mapper_AlgorithmsGlobalTags');
		if(null !== $options) {
			$this->setOptions($options);
		}
	}
}
?>