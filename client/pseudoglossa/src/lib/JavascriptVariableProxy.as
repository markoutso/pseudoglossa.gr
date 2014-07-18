package lib
{
	import flash.external.ExternalInterface;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	public dynamic class JavascriptVariableProxy extends Proxy
	{
		// ======================================== Javascript variable passthrough ========================================
		/**
		 * The method that's invoked when a property is retrieved from this object. Retrieves the variable
		 * from the javascript environment.
		 * 
		 * @private
		 */
		override flash_proxy function getProperty(name:*):*
		{
			return ExternalInterface.call("function() { return " + name.toString() + "; }");
		}
		
		/**
		 * The method that's invoked when a property is set on this object. Passes the variable through
		 * to the javascript environment.
		 * 
		 * @private
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			ExternalInterface.call("function() { " + name + " = '" + value.toString() + "'; }");
		}

	}
}