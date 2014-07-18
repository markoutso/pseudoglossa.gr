<?php
class Default_Model_Mapper_Algorithm extends ss_Db_Mapper
{
	public function __construct()
	{
		$this->modelClass = 'Default_Model_Algorithm';
		parent::__construct('Default_Model_DbTable_Algorithm');
	}
	public function save(ss_Db_Model $algorithm)
	{
		$data = $algorithm->getData();
		if(null === ($id = $algorithm->id)) {
			unset($data['id']);
			$data['created'] = null;
			return $this->dbTable->insert($data);
		} else {
			$data['updated'] = null;
			return $this->dbTable->update($data, array('id = ?' => $id));
		}
	}	
}