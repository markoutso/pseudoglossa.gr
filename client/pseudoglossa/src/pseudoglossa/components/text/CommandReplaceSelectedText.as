package pseudoglossa.components.text
{
	import flash.text.TextField;
	
	//import flight.commands.IUndoableCommand;
	
	/**
	 * For handling cut/paste operations
	 */
	public class CommandReplaceSelectedText implements IUndoableTextCommand
	{
		public var textField:TextField;
		public var oldText:String = "";
		public var oldSelection:Array
		public var text:String = "";
		public var selection:Array;
		public var index:uint;
		
		public function CommandReplaceSelectedText(textField:TextField, oldText:String, oldSelection:Array, text:String, selection:Array)
		{			
			this.textField = textField;		
			this.oldText = oldText.replace(/\r/g, '\n');
			this.oldSelection = oldSelection;
			this.text = text.replace(/\r/g, '\n');
			this.selection = selection;
		}

		public function execute():Boolean
		{
			return true;
		}
		public function undo():void
		{
			textField.replaceText(oldSelection[0], oldSelection[0] + text.length, oldText);
			textField.setSelection(oldSelection[0], oldSelection[1]);
		}
		
		public function redo():void
		{
			textField.replaceText(oldSelection[0], oldSelection[1], text);
			textField.setSelection(selection[0], selection[1]);
		}
		
		public function get undoSpan():Array
		{
			return [oldSelection[0], oldSelection[0] + text.length];	
		}
		
		public function get redoSpan():Array
		{
			return [oldSelection[0], oldSelection[0] + text.length];			
		}
	}
}