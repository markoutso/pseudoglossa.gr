<?php
function __($key)
{
	$key = strtolower($key);
	return isset($GLOBALS['lang'][$key]) ? $GLOBALS['lang'][$key] : $key;
}
function afterLast($haystack, $needle)
{
	return substr(strrchr($haystack, $needle), 1);
}

if(!function_exists('lcfirst')) {
	function lcfirst($str)
	{
		$str[0] = strtolower($str[0]);
		return $str;
	}
}

define('TAG_DELIMITER', 'ϡ');