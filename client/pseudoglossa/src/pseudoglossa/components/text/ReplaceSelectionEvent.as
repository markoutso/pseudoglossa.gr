package pseudoglossa.components.text
{
	import flash.events.Event;
	
	public class ReplaceSelectionEvent extends Event 
	{
		public var oldSelection:Array;
		public var oldText:String;
		public var selection:Array;
		public var text:String;
		public static const REPLACE_SELECTION:String = 'replaceSelection';
		public function ReplaceSelectionEvent(oldSelection:Array, oldText:String, selection:Array, text:String) 
		{
			this.oldSelection = oldSelection;
			this.oldText = oldText;
			this.selection = selection;
			this.text = text;
			
			super(REPLACE_SELECTION, true, true);
		}	
	
	}
}
