<?php
class Default_Model_Mapper_User extends ss_Db_Mapper
{
	public function __construct()
	{
		$this->modelClass = 'Default_Model_User';
		parent::__construct('Default_Model_DbTable_User');
	}
	public function save(ss_Db_Model $user)
	{
		$data = $user->getData();
		if(null !== $user->password) {
			$data['password'] = md5($user->password);
		}
		else {
			unset($data['password']);
		}
		if(isset($data['dateRegistered']) && empty($data['dateRegistered'])) {
			unset($data['dateRegistered']);
		}
		if($data['settings'] instanceof stdClass) 
		{
			$data['settings'] = json_encode($data['settings']);
		}
		if(null === ($id = $user->id)) {
			unset($data['id']);
			return $this->dbTable->insert($data);
		} else {
			return $this->dbTable->update($data, array('id = ?' => $id));
		}
	}	
	public function find()
	{
		$args = func_get_args();
		$data = parent::find($args);
		//var_dump($data);
		$data['settings'] = json_decode($data['settings']);
		return $data;
	}
}
?>