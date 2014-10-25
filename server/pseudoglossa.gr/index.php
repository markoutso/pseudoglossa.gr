<?php
	$sid = session_id() || session_start();
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html>
	<head>
		<title>On-line διερμηνευτής για την Ψευδογλώσσα της ΑΕΠΠ</title>				
<style type="text/css" media="screen">
<!--
  html, body{ height:100%; }
  body { margin:0; padding:0; overflow:hidden; }
-->
</style>		
<script type="text/javascript" src="js/swfobject.js"></script>
<script type="text/javascript">
    //<![CDATA[
var flashvars = {};
flashvars.sessionId = "<?php echo $sid ?>";
var params = {};
params.loop = "false";
params.quality = "high";
params.bgcolor = "#869ca7";
params.allowscriptaccess = "sameDomain";
var attributes = {};
attributes.id = "pseudoglossa";
swfobject.embedSWF("swf/Pseudoglossa.swf?t=<?php echo time(); ?>", "flashAlternative", "100%", "100%", "9.0.15", false, flashvars, params, attributes);    //]]>
</script>		
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="Content-Language" content="el-GR" />
<meta http-equiv="keywords" content="εκτέλεση, αλγόριθμος, ψευδογλώσσα, γλώσσα, ΑΕΠΠ, Α.Ε.Π.Π., προγραμματισμός" />	
</head>
	<body>
		<div id="flashAlternative">
			Παρακαλώ εγκαταστήστε τον flash player
		</div>

	</body>
</html>
