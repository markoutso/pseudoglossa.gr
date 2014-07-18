<?php
class Default_Model_DbTable_User extends ss_Db_Table
{
	public $_name = 'users';
	public $name = 'users';
	public $_primary = 'id';
	public $_dependentTables = array('groups', 'groups-users', 'exercises','teachers-students', 'algorithms');
	public $_sequence = true;
	public $_referenceMap = array (
		'AlgorithmOwnership' => array('columns' => 'id', 'refTableClass' => 'Default_Model_DbTable_Algorithm', 'refColumns' => 'ownerId')
	);
}
?>