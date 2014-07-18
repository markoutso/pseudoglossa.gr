<?php

$translate = new Zend_Translate('array',
	array(
		ss_Validate_FormToken::NOT_SAME => 'Αδυναμία εκτέλεσης ενέργειας', 
		Zend_Validate_Db_NoRecordExists::ERROR_RECORD_FOUND => 'Το στοιχείο χρησιμοποιείται ήδη από κάποιον χρήστη'
	),'el');

Zend_Form::setDefaultTranslator($translate);