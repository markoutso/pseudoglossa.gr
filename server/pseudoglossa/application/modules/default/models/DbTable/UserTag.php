<?php 
class Default_Model_DbTable_UserTag extends ss_Db_Table
{
	public $_name = 'user_tags';
	public $name = 'user_tags';
	public $_primary = 'id';
	public $_dependentTables = array('users');
	public $_sequence = true;
}