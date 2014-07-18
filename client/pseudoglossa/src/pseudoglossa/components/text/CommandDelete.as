/*
  Copyright (c) 2009 Jacob Wright
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
*/
package pseudoglossa.components.text
{
	import flash.text.TextField;
	
	import flight.commands.ICombinableCommand;
	

	public class CommandDelete implements IUndoableTextCommand, ICombinableCommand
	{
		public var textField:TextField;
		public var deletedText:String;
		public var selection:Array;
		public var span:Array;
		public var index:uint;
		
		public function CommandDelete(textField:TextField, oldText:String, oldSelection:Array)
		{
			this.textField = textField;
			selection = oldSelection;
			span = selection.concat();
			index = textField.selectionBeginIndex;
			oldText = oldText.replace(/\r/g, '\n');
			if (span[0] != span[1]) {
				deletedText = oldText.substring(span[0], span[1]);
			} else {
				var lastIndex:uint = span[0];
				if (index < lastIndex) {
					deletedText = oldText.substring(index, lastIndex);
					span[0] = index;
				} else {
					deletedText = oldText.substr(index, 1);
					span[1] = index + 1;
				}
			}
		}
		
		public function get combining():Boolean
		{
			return true;
		}
		
		public function execute():Boolean
		{
			return true;
		}

		public function undo():void
		{
			textField.replaceText(index, index, deletedText);
			textField.setSelection(selection[0], selection[1]);
		}
		
		public function redo():void
		{
			textField.replaceText(span[0], span[1], '');
			textField.setSelection(index, index);
		}
		
		public function combine(command:ICombinableCommand):Boolean
		{
			var deleteCommand:CommandDelete = command as CommandDelete;
			if (deleteCommand.selection[0] != index && deleteCommand.selection[1] != index) {
				return false;
			}
			
			
			if (deleteCommand.index < index) {
				// if backspace was pressed
				deletedText = deleteCommand.deletedText + deletedText;
				span[0]--;
			} else {
				// delete was pressed
				deletedText += deleteCommand.deletedText;
				span[1]++;
			}
			
			index = deleteCommand.index;
			
			return true;
		}
		
		public function get undoSpan():Array
		{
			return span;
		}
		
		public function get redoSpan():Array
		{
			return [index, index];	
		}
	}
}