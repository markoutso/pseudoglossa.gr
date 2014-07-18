package pseudoglossa.components.text
{
	import flash.events.Event;
	
	public class ReplaceEvent extends Event 
	{
		public var pos:uint;
		public var oldText:String;
		public var selection:Array;
		public var text:String;
		public static const REPLACE:String = 'replace';
		
		public function ReplaceEvent(pos:uint, oldText:String, text:String, selection:Array) 
		{
			this.pos = pos;
			this.selection = selection;
			this.oldText = oldText;
			this.text = text;
			
			super(REPLACE, true, true);
		}	
		
	}
}
