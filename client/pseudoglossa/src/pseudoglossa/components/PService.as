package pseudoglossa.components 
{
	import mx.controls.Alert;
	import mx.managers.CursorManager;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.messaging.channels.SecureAMFChannel;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.Operation;
	import mx.rpc.remoting.RemoteObject;
	import mx.utils.ObjectUtil;
	
	public class PService extends RemoteObject
	{
		protected var amfChannel:AMFChannel;	
		public var actionStack:Object;
		private var cursorListeners:Object;
		private var listeners:Object;
		
		public static const LISTEN_ONCE:String = 'once';
		public static const LISTEN_ALWAYS:String = 'always';
			
		public function PService(url:String = 'http://localhost/pseudoglossa/public/amf.php')
		{	
			super('zend');
			actionStack = new Object();
			if (url.indexOf('https') == 0) {
				amfChannel = new SecureAMFChannel('zend-endpoint', url);
			} else {
				amfChannel = new AMFChannel('zend-endpoint', url);
			}
			channelSet = new ChannelSet();
			channelSet.addChannel(amfChannel);
			requestTimeout = 30;
			addEventListener('fault', faultHandler);
			addEventListener('result', resultHandler);		
			listeners = {};
		}		
		public function call(method:String, ...params:Array):void 
		{
			CursorManager.setBusyCursor();
			if(!methodInitialised(method)) {
				initMethod(method);							
			}						
			if(params[params.length - 1] is Function) {
				addResultListener(method, params[params.length - 1] as Function, LISTEN_ONCE);
				params.splice(params[length - 1], 1);
			}
			else if(params[params.length - 2] is Function) {
				addResultListener(method, params[params.length - 2] as Function, params[params.length - 1]);
				params.splice(params[length - 2], 2);
			}
			getOperation(method).send.apply(null, params);
			//execStack(method);			
		}
		
		private function initMethod(method:String):void 
		{
			getOperation(method).addEventListener(ResultEvent.RESULT, globalListener);
			listeners[method] = [];			
			listeners[method][LISTEN_ALWAYS] = [removeBusyCursor];
			listeners[method][LISTEN_ONCE] = [];			
		}
		private function methodInitialised(method:String):Boolean {
			return listeners.hasOwnProperty(method)
		}
		private function removeBusyCursor(e:Object):void
		{
			CursorManager.removeBusyCursor();
		}
		private function globalListener(e:ResultEvent):void
		{
			var method:String = e.currentTarget.name;
			/*if(e.result
			&& e.result.hasOwnProperty('trigger')) {
				var actions:Array = e.result.trigger as Array;
				for each(var action:String in actions) {
					notifyListeners(action, e);		
				} 
			}*/
			notifyListeners(method, e);
			
		}
		private function notifyListeners(method:String, e:ResultEvent):void
		{
			listeners[method][LISTEN_ALWAYS].forEach(function(l:Function, ...params):void {
				l(e);
			});
			listeners[method][LISTEN_ONCE].forEach(function(l:Function, ...params):void {
				l(e);
			});
			listeners[method][LISTEN_ONCE] = [];
			
		}
		public function removeListener(method:String, listener:Function, listenMode:String = LISTEN_ALWAYS):void 
		{
			listeners[method][listener][listenMode] = 
				listeners[method][listener][listenMode].filter(function(f:Function, ...params):Boolean {
					return f != listener;
				});			
		}
		public function clearMethodListeners(method:String, listenMode:String = LISTEN_ALWAYS):void
		{
			listeners[method][listenMode] = [];
		}
		public function addResultListener(method:String, listener:Function, listenMode:String = LISTEN_ALWAYS):void
		{					
			if(!methodInitialised(method)) {
			 	initMethod(method);
			}			
			listeners[method][listenMode].push(listener);
		}
		private function resultHandler(e:ResultEvent):void 
		{			
			Alert.show(e.result.toString());			
		}
		private function faultHandler(e:FaultEvent):void
		{
			if(e.fault.faultString == 'sessionError') {
				call('pLogout');
				ErrorDialog.showError('Λήξη συνεδρίας. Παρακαλώ εισέλεθετε ξανά στο σύστημα. Επιλέξτε "Να με θυμάσαι" από το παράθυρο εισόδου εάν επιθυμείτε να μην λήγουν οι συνεδρίες σας.');	
			}
			else {
				ErrorDialog.showError(e.toString());	
			}
				
			CursorManager.removeBusyCursor();	
		}
	}
}