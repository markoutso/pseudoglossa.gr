<?php
class Default_Model_DbTable_Algorithm extends ss_Db_Table
{
	public $_name = 'algorithms';
	public $name = 'algorithms';
	public $_primary = 'id';
	public $_dependentTables = array('users');
	public $_sequence = true;
	public $_referenceMap = array (
		'AlgorithmOwnership' => 
			array('columns' => 'userId', 
				'refTableClass' => 'Default_Model_DbTable_User', 
				'refColumns' => 'id'
			),
		'UserTags' =>
			array(
				'columns' => 'id',
				'refTableClass' => 'Default_Model_DbTable_AlgorithmsUserTags',
				'refColumns' => 'algorithmId'
			),
		'GlobalTags' =>
			array(
				'columns' => 'id',
				'refTableClass' => 'Default_Model_DbTable_AlgorithmsGlobalTags',
				'refColumns' => 'algorithmId'
			),
	);
}