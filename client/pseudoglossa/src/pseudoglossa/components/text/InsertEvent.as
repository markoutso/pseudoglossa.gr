package pseudoglossa.components.text
{
	import flash.events.Event;
	
	public class InsertEvent extends Event 
	{
		public var pos:int;
		public var text:String;
		public var selection:Array;
		public static const INSERT:String = 'insert';
		
		public function InsertEvent(pos:int, text:String, oldSelection:Array) 
		{
			this.pos = pos;
			this.text = text;
			this.selection = oldSelection;
			super(INSERT, true, true);
		}	
		
	}
}
