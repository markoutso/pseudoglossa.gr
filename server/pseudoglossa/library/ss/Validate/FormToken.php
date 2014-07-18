<?php 
class ss_Validate_FormToken extends Zend_Validate_Abstract
{
	const NOT_SAME      = 'notSame';

	protected $_messageTemplates = array(
		self::NOT_SAME      => 'Tokens do not match',
	);

	public function isValid($value)
	{
		$session = Zend_Registry::get('session');
		if(empty($value) || $value != (string)$session->formToken) {
			$this->_error(self::NOT_SAME); 
    		return false;
		}
		return true;
	}
}
