<?php
class ss_Db_Table extends Zend_Db_Table_Abstract
{
	public function getPrimary()
	{
		return $this->_primary;
	}
}