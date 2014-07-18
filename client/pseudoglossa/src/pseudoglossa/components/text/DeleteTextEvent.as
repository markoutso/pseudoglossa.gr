package pseudoglossa.components.text
{
	import flash.events.Event;
	
	public class DeleteTextEvent extends Event 
	{
		public var pos:uint;
		public var text:String;
		public static const DELETE_TEXT:String = 'deleteText';
		public function DeleteTextEvent(pos:uint, text:String) 
		{
			this.pos = pos;
			this.text = text;
			
			super(DELETE_TEXT, true, true);
		}	
		
	}
}
