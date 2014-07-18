package pseudoglossa.components.text
{
	import flash.text.TextField;
	
	import flight.commands.IUndoableCommand;

	public class CommandInsertText implements IUndoableTextCommand
	{
		public var textField:TextField;
		public var pos:int;
		public var text:String;
		public var selection:Array;
		
		public function CommandInsertText(textField:TextField, pos:int, text:String, oldSelection:Array)
		{			
			this.textField = textField;		
			this.pos = pos;
			this.text = text.replace(/\r/g, '\n');
			this.selection = oldSelection;		
		}

		public function execute():Boolean
		{
			return true;
		}
		public function undo():void
		{
			textField.replaceText(pos, pos + text.length, '');
			textField.setSelection(selection[0], selection[1]);
		}
		
		public function redo():void
		{
			textField.replaceText(selection[1], selection[1], text);
			textField.setSelection(selection[1] + text.length, selection[1] + text.length);
		}
		
		public function get undoSpan():Array
		{
			return [pos, pos];
		}
		
		public function get redoSpan():Array
		{
			return [pos, pos];	
		}
		
	}
}