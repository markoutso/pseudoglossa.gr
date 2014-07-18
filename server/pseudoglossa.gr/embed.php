<?php
$filename = realpath(dirname(__FILE__)) . DIRECTORY_SEPARATOR . 'swf'. DIRECTORY_SEPARATOR . 'PseudoglossaEmbedded.swf';
$length = filesize($filename);
header("Content-type: application/x-shockwave-flash",true);
header("Content-Length: {$length}",true);
header("Accept-Ranges: bytes",true);
header("Connection: keep-alive",true);
readfile($filename);
exit;
?>