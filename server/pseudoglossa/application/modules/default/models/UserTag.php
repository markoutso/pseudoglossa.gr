<?php
class Default_Model_UserTag extends ss_Db_Model
{
	public $id;
	public $userId;
	public $name;
	
	public $owner;
	
	public $tableCols = array('id', 'userId', 'name');
	
	public function __construct($options = null)
	{
		parent::__construct('Default_Model_Mapper_UserTag');
		if(null !== $options) {
			$this->setOptions($options);
		}
	}
}
?>