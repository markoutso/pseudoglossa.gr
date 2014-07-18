<?php
class ss_Object
{	
	public function __construct($obj = null)
	{
		if($obj) {
			$this->copyProperties($obj);
		}
		//$this->properties = get_object_vars($this);
	}
	public function hasProperty($property)
	{
		return isset($this->$property);			
	}
	public function mapProperties($arr)
	{
		foreach($this as $key => $value) {
			if(isset($arr[$key])) {
				$this->$key = $arr[$key];
			}
		}
	}
	public function copyProperties($arr) {
		foreach($arr as $key=>$value) {
			$this->$key = $value;
		}
	}
	public function getData()
	{
		$data = array();
		foreach($this as $key => $value) {
			$data[$key] = $value;
		}
		return $data;
	}
	public function setOptions($options)
	{
		foreach($options as $key => $value)	{
			if($this->hasProperty($key)) {
				$this->$key = $value;	
			} else {
				throw new Exception('Τα αντικείμενα τύπου '. get_class($this). ' δεν έχουν την ιδιότητα ' . $key);
			}
		}
		return $this;
	}
	public function dump($die = false)
	{
		if($die) {
			die(var_dump($this));
		} else {
			var_dump($this);
		}
	}
} 
?>