<?php
class Default_Model_Mapper_Group extends ss_Db_Mapper
{
	public function __construct()
	{
		parent::__construct('Default_Model_DbTable_Group', 'Default_Model_Group');
	}
	public function listSelect()
	{
		$select = $this->dbTable->select(true)->setIntegrityCheck(false)
		->from(array('groups'))
		->join('users', 'groups.ownerId = users.id', array('*'));	
		return $select;		       
	}
	public function save(Default_Model_group $group)
	{
		$data = $group->getData();
		if(null === ($id = $group->getId())) {
			unset($data['id']);
			$this->dbTable->insert($data);
		} else {
			$this->dbTable->update($data, array('id = ?' => $id));
		}
	}	
}
?>