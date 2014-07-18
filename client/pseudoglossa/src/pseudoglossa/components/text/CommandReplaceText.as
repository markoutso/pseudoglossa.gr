package pseudoglossa.components.text
{
	import flash.text.TextField;
	
	
	/**
	 * For handling cut/paste operations
	 */
	public class CommandReplaceText implements IUndoableTextCommand
	{
		public var textField:TextField;
		public var pos:uint;
		public var oldText:String = "";
		public var selection:Array
		public var text:String = "";
		
		public function CommandReplaceText(textField:TextField, pos:uint, oldText:String, text:String, selection:Array)
		{			
			this.textField = textField;
			this.pos = pos;
			this.oldText = oldText.replace(/\r/g, '\n');
			this.text = text.replace(/\r/g, '\n');
			this.selection = selection;
		}
		
		public function execute():Boolean
		{
			return true;
		}
		public function undo():void
		{
			var diff:int = oldText.length - text.length;
			textField.replaceText(pos, pos + text.length, oldText);
			textField.setSelection(selection[0] + diff, selection[1] + diff);
		}
		
		public function redo():void
		{
			var diff:int = text.length - oldText.length;
			textField.replaceText(pos, pos + oldText.length, text);
			textField.setSelection(selection[0] + diff, selection[1] + diff);
		}
		
		public function get undoSpan():Array
		{
			return [pos, pos + oldText.length];	
		}
		
		public function get redoSpan():Array
		{
			return [pos, pos + text.length];			
		}
	}
}