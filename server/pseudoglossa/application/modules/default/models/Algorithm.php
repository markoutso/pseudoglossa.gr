<?php
class Default_Model_Algorithm extends ss_Db_Model
{
	public $id;
	public $userId;
	public $created;
	public $updated;
	public $name;
	public $body;
	public $inputFile;
	public $notes;
	
	public $tableCols = array('id', 'userId', 'created', 'updated', 'name', 'body', 'notes', 'inputFile');
	
	public function __construct($options = null)
	{
		parent::__construct('Default_Model_Mapper_Algorithm');
		if(null !== $options) {
			$this->setOptions($options);
		}
	}
}
?>