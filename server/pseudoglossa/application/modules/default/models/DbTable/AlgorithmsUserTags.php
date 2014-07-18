<?php 
class Default_Model_DbTable_AlgorithmsUserTags extends ss_Db_Table
{
	public $_name = 'algorithms-user_tags';
	public $name = 'algorithms-user_tags';
	public $_primary = array('algorithmId', 'userTagId');
	public $_sequence = true;
	public $_referenceMap = array (
		'Algorithm' => 
			array('columns' => 'algorithmId', 
				'refTableClass' => 'Default_Model_DbTable_Algorithm', 
				'refColumns' => 'id'
			)
	);
}