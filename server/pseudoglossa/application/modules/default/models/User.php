<?php
class Default_Model_User extends ss_Db_Model
{
	public $id;
	public $username;
	public $password;
	public $email;
	public $firstName;
	public $lastName;
	public $settings;
	/*public $role;
	public $avatar;
	public $signature;
	public $parents;
	*/
	public $dateRegistered;
	
	public $tableCols = array('id','username', 'password', 'email', 'firstName', 'lastName', 'dateRegistered', 'settings');
	
	public function __construct($options = null)
	{
		parent::__construct('Default_Model_Mapper_User');
		if(null !== $options) {
			$this->setOptions($options);
		}
	}
}
?>