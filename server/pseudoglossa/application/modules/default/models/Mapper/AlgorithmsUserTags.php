<?php
class Default_Model_Mapper_AlgorithmsUserTags extends ss_Db_Mapper
{
	public function __construct()
	{
		$this->modelClass = 'Default_Model_AlgorithmsUserTags';
		parent::__construct('Default_Model_DbTable_AlgorithmsUserTags');
	}
	public function save(Default_Model_AlgorithmsUserTags $algorithmUserTags)
	{
		$data = $algorithmUserTags->getData();
		return $this->dbTable->insert($data);		
	}	
}
?>