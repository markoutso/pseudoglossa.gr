<?php
abstract class ss_Db_Mapper extends ss_Object
{
	public $dbTable;
	public $row;
	public $primary;
	
	public function __construct($dbTable = null, $modelClass = null)
	{
		if($dbTable) {
			$this->setDbTable($dbTable);
		}
		$this->modelClass = $modelClass;
	}
	public function setDbTable($dbTable)
	{
		if(is_string($dbTable)) {
			$dbTable = new $dbTable();
		}
		if(!$dbTable instanceof Zend_Db_Table_Abstract) {
			throw new Exception("Το $dbTable δεν αντιστοιχεί σε πίνακα της βάσης");
		}
		$this->primary = $dbTable->getPrimary();
		$this->dbTable = $dbTable;
		return $this;
	}
	public function save(ss_Db_Model $object)
	{
		$data = $object->getData();
		if(!$object->id) {
			unset($data['id']);
			$object->id = $this->getDbTable()->insert($data);
		}
		else {
			$this->getDbTable()->update($data, array('id = ?' => $id));
		}
	}
	public function delete(ss_Db_Model $object)
	{		
		if(is_string($this->primary)) {
			$p = $this->primary;
			$v = $object->$p;		
			$w = "$p = ?";
			$where = $this->dbTable->getAdapter()->quoteInto($w, $v);
		} elseif(is_array($this->primary)) {
			$where = '';
			$i = 0;
			foreach($this->primary as $p) {
				$i++;
				$v = $object->$p;
				$w = "$p = ?";
				if($i > 1) {
					$where .= ' AND ';
				}
				$where .= $this->dbTable->getAdapter()->quoteInto($w, $v);
			}
		}
		$this->dbTable->delete($where);
	}
	public function find()
	{		
		$args = func_get_args();
		$result = call_user_func_array(array($this->dbTable, 'find'), $args);
		if(0 == count($result)) {
			return;
		}
		$this->row = $result->current();
		return $this->row;
	}
	public function fetchRow($where) 
	{
		$args = func_get_args();
		$result = call_user_func_array(array($this->dbTable, 'fetchRow'), $args);
		if(0 == count($result)) {
			return;
		}
		$this->row = $result;
		return $this->row;	
	}
	public function fetchAll()
	{
		return $this->dbTable->fetchAll();		
	}	
	public function listSelect()
	{
		return $this->dbTable->select();
	}
}
?>