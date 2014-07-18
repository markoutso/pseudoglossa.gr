<?php
class Default_Model_Mapper_AlgorithmsGlobalTags extends ss_Db_Mapper
{
	public function __construct()
	{
		$this->modelClass = 'Default_Model_AlgorithmsGlobalTags';
		parent::__construct('Default_Model_DbTable_AlgorithmsGlobalTags');
	}
	public function save(Default_Model_AlgorithmsGlobalTags $algorithmGlobalTags)
	{
		$data = $algorithmGlobalTags->getData();
		return $this->dbTable->insert($data);		
	}	
}
?>