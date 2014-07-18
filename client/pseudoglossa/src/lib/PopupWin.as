//http://www.mehtanirav.com/2008/11/27/opening-external-links-in-new-window-from-as3/
package lib
{
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	public class PopupWin
	{
		public static var baseURL:String = '';
		private static var browserName:String = '';
		public static function openWindow(url:String, target:String = '_blank', features:String=""):void
		{
			//Sets function name into a variable to be executed by ExternalInterface.
			//Otherwise Flex will try to find a local function or value by that name.
			var WINDOW_OPEN_FUNCTION:String = "window.open";
			// Prefix baseURL if specified
			if (PopupWin.baseURL != '')
			{
				url = PopupWin.baseURL + url;
			}
			var myURL:URLRequest = new URLRequest(url);
			if (PopupWin.browserName == '')
			{
				PopupWin.browserName = PopupWin.getBrowserName();
			}
			switch (PopupWin.browserName)
			{
				//If browser is Firefox, use ExternalInterface to call out to browser
				//and launch window via browser's window.open method.
				case "Firefox":
					ExternalInterface.call(WINDOW_OPEN_FUNCTION, url, target, features);
				   break;
				//If IE,
				case "IE":
					ExternalInterface.call("function setWMWindow() {window.open('" + url + "', '"+target+"', '"+features+"');}");
					break;
				// If Safari or Opera or any other
				case "Safari":
				case "Opera":
				default:
					navigateToURL(myURL, target);
					break;
			}
			/*Alternate methodology...
			   var popSuccess:Boolean = ExternalInterface.call(WINDOW_OPEN_FUNCTION, url, target, features);
			if(popSuccess == false){
				navigateToURL(myURL, target);
			}*/
		}
		private static function getBrowserName():String
		{
			var browser:String;
			//Uses external interface to reach out to browser and grab browser useragent info.
			var browserAgent:String = ExternalInterface.call("function getBrowser(){return navigator.userAgent;}");
			//Determines brand of browser using a find index. If not found indexOf returns (-1).
			if(browserAgent != null && browserAgent.indexOf("Firefox")>= 0) {
				browser = "Firefox";
			}
			else if(browserAgent != null && browserAgent.indexOf("Safari")>= 0){
				browser = "Safari";
			}
			else if(browserAgent != null && browserAgent.indexOf("MSIE")>= 0){
				browser = "IE";
			}
			else if(browserAgent != null && browserAgent.indexOf("Opera")>= 0){
				browser = "Opera";
			}
			else {
				browser = "Undefined";
			}
			return (browser);
		}
		public static function showHelp(screen:String = 'home') :void
		{
			//var features:String = "menubar=yes,status=no,toolbar=yes,location=1,scrollbars=yes,resizable=1";
			PopupWin.openWindow(screen, '_help');
		}
	}
}


