package pseudoglossa.components.text
{
	import flash.events.Event;
	
	import pseudoglossa.components.text.IUndoableTextCommand;	
	
	public class UndoTextEvent extends Event 
	{
		public var undoType:String;
		public var command:IUndoableTextCommand;
		public static const UNDO:String = 'undo';
		public static const REDO:String = 'redo';

		
		public function UndoTextEvent(undoType:String, command:IUndoableTextCommand) 
		{
			super(UNDO, true, true);
			this.undoType = undoType;
			this.command = command;			
		}	
		
	}
}
