<?php 
class Default_Model_Amf_User extends ss_Object
{
	public $_explicitType = 'pseudoglossa.models.User';
	
	public $username = '';
	public $firstName = '';
	public $lastName = '';
	public $password = '';
	public $email = '';
	public $settings = '';
	
	public function getASClassName()
	{
		return 'pseudoglossa.models.User';
	}
}