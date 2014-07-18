package pseudoglossa.components.text
{
	import flash.text.TextField;
	
	
	/**
	 * For handling cut/paste operations
	 */
	public class CommandDeleteText implements IUndoableTextCommand
	{
		public var textField:TextField;
		public var text:String = "";
		public var index:uint;
		
		public function CommandDeleteText(textField:TextField, index:uint, text:String)
		{			
			this.textField = textField;
			this.index = index;
			this.text = text.replace(/\r/g, '\n');
		}
		
		public function execute():Boolean
		{
			return true;
		}
		public function undo():void
		{
			textField.replaceText(index, index, text);
		}
		
		public function redo():void
		{
			textField.replaceText(index, index + text.length, '');
		}
		
		public function get undoSpan():Array
		{
			return [index, index + text.length];	
		}
		
		public function get redoSpan():Array
		{
			return [index, index];			
		}
	}
}