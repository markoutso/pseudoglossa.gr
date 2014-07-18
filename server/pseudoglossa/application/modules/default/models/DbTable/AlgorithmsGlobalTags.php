<?php 
class Default_Model_DbTable_AlgorithmsGlobalTags extends ss_Db_Table
{
	public $_name = 'algorithms-global_tags';
	public $name = 'algorithms-global_tags';
	public $_primary = array('algorithmId', 'globalTagId');
	public $_sequence = true;
	public $_referenceMap = array (
		'Algorithm' => 
			array('columns' => 'algorithmId', 
				'refTableClass' => 'Default_Model_DbTable_Algorithm', 
				'refColumns' => 'id'
			)
	);
}