<?php
class Default_Model_DbTable_Group extends ss_Db_Table
{
	public $_name = 'groups';
	public $name = 'groups';
	protected $_dependentTables = array('users');
	protected $_referenceMap    = array(
		'Owner' => array(
            'columns'           => 'userId',
            'refTableClass'     => 'Default_Model_DbTable_User',
            'refColumns'        => 'id'
        )
   );
}
?>