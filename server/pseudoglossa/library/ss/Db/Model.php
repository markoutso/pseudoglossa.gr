<?php
abstract class ss_Db_Model extends ss_Object
{
	public $mapper;
	public $tableCols;
	
	public function __construct($mapper = null) 
	{
		if($mapper) {
			$this->setMapper($mapper);
		}
	}
	public function setMapper($mapper)
	{
		if(is_string($mapper)) {
			$mapper = new $mapper();
		}
		if(!($mapper instanceof ss_Db_Mapper)) {
			throw new Exception('Τα αντικείμενα τύπου ' . get_class($mapper) . ' δεν μπορούν να χρησιμοποιηθούν για την χαρτογράφηση αντικειμένων');
		}
		$this->mapper = $mapper;
	}
	public function getData()
	{
		$data = array();
		foreach($this->tableCols as $key) {
			//if(!empty($this->$key)) {
				$data[$key] = $this->$key;
			//}
		}
		return $data;
	}
	public function mapProperties($arr)
	{
		foreach($this->tableCols as $k) {
			if(isset($arr[$k])) {
				$this->$k = $arr[$k];
			}
		}
	}
	public function toArray() {
		$arr = array();
		foreach($this->tableCols as $k) {
			$arr[$k] = $this->$k;
		}		
		return $arr;
	}
	public function toObject() {
		return (object)$this->toArray();
	}
	public function getForm($setToken = true)
	{
		$name = $this->modelName();
		$class = 'Default_Form_' . $name;
		$form = new $class(array('model'=> $this, 'name' => lcfirst($name)));
		if($setToken) {
			$form->setToken();			
		}
		return $form;
	}
	public function modelName()
	{
		return afterLast(get_class($this), '_');
	}
	public function save()
	{
		$primary = $this->mapper->dbTable->getPrimary();
		$res = $this->mapper->save($this);
		if(is_string($res)) {
			$this->$primary = $res;
		}
		return $this;
	}
	public function delete()
	{
		$this->mapper->delete($this);
		return $this;
	}
	public function find($id)
	{
		$row = $this->mapper->find($id);		
		$this->mapProperties($row);
		return $this;
	}
	public function fetchRow($where)
	{
		$row = $this->mapper->fetchRow($where);		
		$this->mapProperties($row);
		return $this;		
	}
	public function fetchAll()
	{
		$entries = array();
		$resultSet = $this->mapper->fetchAll();
		foreach($resultSet as $row) {
			$entry = new $this->modelClass();
			$entry->mapProperties($row);
			$entries[] = $entry;		
		}
		return $entries;
	}
	
	public function getPaginator()
	{
		return new Zend_Paginator(new Zend_Paginator_Adapter_DbSelect($this->mapper->listSelect()));
	}
}
?>