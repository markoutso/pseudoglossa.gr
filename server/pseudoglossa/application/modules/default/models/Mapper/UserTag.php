<?php
class Default_Model_Mapper_UserTag extends ss_Db_Mapper
{
	public function __construct()
	{
		$this->modelClass = 'Default_Model_UserTag';
		parent::__construct('Default_Model_DbTable_UserTag');
	}
	public function save(ss_Db_Model $userTag)
	{
		$data = $userTag->getData();
		if(null === ($id = $userTag->id)) {
			unset($data['id']);	
			return $this->dbTable->insert($data);
		} else {
			return $this->dbTable->update($data, array('id = ?' => $id));
		}
	}	
}