package pseudoglossa.components.text
{
			
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.textClasses.TextRange;
	import mx.core.Application;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import pseudoglossa.components.text.UndoTextEvent;

	[Bindable]
	public class ExtTextArea extends TextArea
	{
		public var tf:TextField;		
		public var undoTF:UndoTextFields;
		public static var wordPattern:RegExp = /[A-Za-zΆ-ώ_0-9]+/;
		
		private var log:Object = {
			selection : [0, 0],
			oldSelection : [0, 0],
			keyAction : '',
			inputText : ''
		}
		
		private var _canUndo:Boolean = false;
		private var _canRedo:Boolean = false;
		
		
		[Bindable(event='undoChanged')]
		public function get canUndo():Boolean
		{
			return _canUndo;	
		}
		
		public function set canUndo(can:Boolean):void
		{
			_canUndo = can;
			dispatchEvent(new Event('undoChanged'));
		}
			
		[Bindable(event='redoChanged')]		
		public function get canRedo():Boolean
		{
			return _canRedo;	
		}
		
		
		public function set canRedo(can:Boolean):void
		{
			_canRedo = can;
			dispatchEvent(new Event('redoChanged'));
		}
		
		public function ExtTextArea()
		{
			super();			
			addEventListener(Event.CHANGE, changeHandler);
			addEventListener(InsertEvent.INSERT, insertHandler);
			addEventListener(ReplaceSelectionEvent.REPLACE_SELECTION, replaceHandler);
			addEventListener(TextEvent.TEXT_INPUT, logInput);
			addEventListener(KeyboardEvent.KEY_UP, logSelection);	
			addEventListener(KeyboardEvent.KEY_DOWN, logKeyAction);	
			addEventListener(MouseEvent.MOUSE_DOWN, function():void
			{
				//logs selection
				Application.application.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			});			
			addEventListener(UndoTextEvent.UNDO, undoHandler);
			
			log.oldSelection = [0, 0];
			log.selection = [0, 0];
			log.keyAction = '';
			log.inputText = '';
			
			undoTF = new UndoTextFields();
			undoTF.target = this;
			
			addEventListener(KeyboardEvent.KEY_DOWN, tabLines);
			
			var that:ExtTextArea = this;
			addEventListener(FlexEvent.CREATION_COMPLETE, function():void 
			{
				var a :Object = that.contextMenu;
				tf = textField as TextField;
				tf.alwaysShowSelection = true;
				tf.selectable = true;
			});
			
			addEventListener(UndoTextFields.ACTION_TEXT_CHANGE, updateUndoAbility);
			addEventListener(ReplaceSelectionEvent.REPLACE_SELECTION, validateAfterEvent);
		}
		
		private function replaceHandler(event:ReplaceSelectionEvent):void
		{
			//trace('replacehandler:' + text.slice(event.selection[0], event.selection[1]));
			dispatchEvent(new ChangeAreaEvent(ChangeAreaEvent.CHANGE_AREA, event.selection));
		}
		private function insertHandler(event:InsertEvent):void 
		{
			//trace('insertHandler:' + text.slice(event.pos, event.pos + event.text.length));
			dispatchEvent(new ChangeAreaEvent(ChangeAreaEvent.CHANGE_AREA, [event.pos, event.pos + event.text.length]));
		}
		
		private function changeHandler(event:Event):void
		{
			if(log.keyAction == 'delete') {
				//trace('delete:' + text.slice(log.selection[0], tf.caretIndex + 1));
				dispatchEvent(new ChangeAreaEvent(ChangeAreaEvent.CHANGE_AREA, [log.selection[0], tf.caretIndex + 1]));
			}
			else if((log.keyAction == 'paste') || (tf.caretIndex - log.selection[0] > 20)) {
				//trace('paste:' + text.slice(log.selection[0], log.selection[0] + log.inputText.length));
				dispatchEvent(new ChangeAreaEvent(ChangeAreaEvent.CHANGE_AREA, [log.selection[0], log.selection[0] + log.inputText.length]));
			} else if(log.keyAction == 'type') {
				if(log.inputText == '\r' || log.inputText == '\n') {
					if(text.length > log.selection[0] + 1) {
						//trace('type:' + text.slice(log.selection[0], log.selection[0] + 2));
						dispatchEvent(new ChangeAreaEvent(ChangeAreaEvent.CHANGE_AREA, [log.selection[0], log.selection[0] + 2]));
					} else {
						//trace('typeold:' + text.slice(log.oldSelection[0], log.oldSelection[0] + 1));
						dispatchEvent(new ChangeAreaEvent(ChangeAreaEvent.CHANGE_AREA, [log.oldSelection[0], log.oldSelection[0] + 1]));
					}
				} else {
					//trace('type:' + text.slice(selectionBeginIndex, selectionEndIndex + 1));
					dispatchEvent(new ChangeAreaEvent(ChangeAreaEvent.CHANGE_AREA, [selectionBeginIndex, selectionEndIndex + 1]));
				}
			}
		}
		
		private function undoHandler(event:UndoTextEvent):void 
		{
			var command:IUndoableTextCommand = event.command;
			var span:Array;
			if(event.undoType == UndoTextEvent.UNDO) {
				span = command.undoSpan;
			} else {
				span = command.redoSpan;
			}
			//trace('undo:' + text.slice(span[0], span[1]));
			dispatchEvent(new ChangeAreaEvent(ChangeAreaEvent.CHANGE_AREA, span));
		}
		private function mouseUpHandler(event:Event):void 
		{
			logSelection();
			Application.application.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
		}
		private function logSelection(event:Event = null):void
		{
			//trace('logSelection: ' + text.slice(selectionBeginIndex, selectionEndIndex));
			log.oldSelection = log.selection;
			log.selection = [selectionBeginIndex, selectionEndIndex];
		}
		
		private function logKeyAction(event:KeyboardEvent):void 
		{
			if (event.keyCode == Keyboard.DELETE || event.keyCode == Keyboard.BACKSPACE) {
				log.keyAction = 'delete';
			} else if (event.charCode) {
				log.keyAction = 'type'
			} else {
				log.keyAction = 'paste';
			}
		}
		private function logInput(event:TextEvent):void
		{
			log.inputText = event.text; 
		}
		private function updateUndoAbility(event:Event):void
		{
			canUndo = undoTF.canUndo(tf);
			canRedo = undoTF.canRedo(tf);
		}
		
		private function validateAfterEvent(event:Event):void
		{
			validateNow();
		}
		
		public function lineAtPos(pos:int):int 
		{
			if(tf.text.charAt(pos) == '') {
				if(tf.text.charAt(pos - 1) == '\r' || tf.text.charAt(pos - 1) == '\n') {
					return tf.getLineIndexOfChar(pos - 1) + 1;
				} else { 
					return tf.getLineIndexOfChar(pos - 1);
				}
			} else { 
				return tf.getLineIndexOfChar(pos);
			}
		}
		
		public function firstCharAtLinePos(pos:int):int
		{
			do {
				pos -= 1;
			} while(pos > 0 && this.tf.text.charAt(pos) != '\r');
			pos = (pos == 0 ? 0 : (pos + 1));
			return pos;
		}
		
		public function lastCharAtLinePos(pos:int):int
		{
			while(pos < text.length && !text.charAt(pos).match(/\n|\r/)) {
				pos += 1;
			}
			return pos;
		}
		
		public function get lineAtCaretPos():int 
		{
			if(this.textField.caretIndex == 0) {
				return 0;			
			}
			return this.lineAtPos(this.textField.caretIndex);
		}
		
		public function search(needle:String, startIndex:int = 0, matchCase:Boolean = true, wholeWord:Boolean = true):int
		{
			var pos:int;
			var haystack:String;
			if(matchCase){
				haystack = this.textField.text.toLowerCase();
				needle = needle.toLowerCase();
			} else {
				haystack = this.textField.text;
			}		 
			if(wholeWord) {
				var wordBefore:Boolean = true;
				var wordAfter:Boolean = true;
				pos = startIndex;
				while((wordBefore || wordAfter) && (pos != -1)) {
					pos = haystack.indexOf(needle, pos);
					wordBefore = pos > 0 && isWordChar(haystack.charAt(pos-1));
					wordAfter = pos + needle.length < haystack.length && isWordChar(haystack.charAt(pos+needle.length));
					if(wordBefore || wordAfter) {
						if(pos + needle.length < haystack.length && pos != -1) {
							pos += needle.length;
						} else {
							pos = -1;
						}
					}	
				}				
			} else {
				pos = haystack.indexOf(needle, startIndex);
			}
			if(pos > -1) {
				this.textField.setSelection(pos, pos + needle.length);
				return pos;
			} else {
				return -1;
			}
		}
		private function isWordChar(char:String):Boolean
		{
			return wordPattern.test(char);
		}
		public function clearUndoHistory():void
		{
			undoTF.clearHistory(tf);
		}
		
		public function replaceSelection(r:String):void 
		{
			var selBegin:int = textField.selectionBeginIndex;
			var selEnd:int = textField.selectionEndIndex;
			if(selBegin != selEnd) {	
				var oldText:String = textField.text.substring(selBegin, selEnd);
				//textField.replaceSelectedText(r);		
				textField.replaceText(selBegin, selEnd, r);
				textField.dispatchEvent(new ReplaceSelectionEvent([selBegin, selEnd], oldText, [selBegin, selBegin + r.length], r));
				textField.setSelection(selBegin, selBegin + r.length);
							
			}
		}
		
		public function insertAtCaretPos(str:String):void 
		{			
			insertAtPos(str, textField.caretIndex);
		}
		
		public function insertAtPos(str:String, pos:uint, notify:Boolean = true):void 
		{
			var vsp:uint = verticalScrollPosition;
			var oldSelection:Array = [textField.selectionBeginIndex, textField.selectionEndIndex];
			new TextRange(this, false, pos, pos).text = str;
			var l:uint = str.length;
			textField.setSelection(pos + l, pos + l);
			
			if(notify) {
				textField.dispatchEvent(new InsertEvent(pos, str, oldSelection));
			}
			
			callLater(function():void {
				verticalScrollPosition = vsp;
			});
		}
		
		public function countCharsFromStart(char:String, iniPos:int):int
		{
			if(	text.length == 0 || iniPos < 0) {
				return 0;
			}
				
			
			var lpos:int = tf.getLineOffset(lineAtPos(iniPos));			
			var i:uint = lpos;
			var count:int = 0;

			while(text.charAt(i) == char && i <= text.length) {
				i += 1;
				count += 1;
			}
			
			return count;
		}
		
		private function trimPos(pos:uint, dir:int = 1):uint
		{
			var limit:uint = dir > 0 ? text.length : -1;
			var check:Function = dir > 0 ? 
				function():Boolean
				{
					return pos < limit;
				} : 
				function():Boolean
				{
					return pos > limit;
				};
			while(text.charAt(pos).match(/\s/) && check()) {
				pos += dir;
			}
			return pos;
		}
		
		public function trimPosLeft(pos:uint):uint
		{
			while(text.charAt(pos).match(/\s/) && pos < text.length) {
				pos -= 1;
			}
			return pos;
			//return trimPos(pos, -1);
		}
		
		public function trimPosRight(pos:uint):uint
		{
			while(text.charAt(pos).match(/\s/) && pos < text.length) {
				pos += 1;
			}
			return pos;
			//return trimPos(pos, 1);
		}
		
		public function firstWordAfterPos(pos:uint):String
		{			
			var word:String = '';
			pos = trimPosRight(pos);			
			while(!text.charAt(pos).match(/\s/) && pos < text.length) {
				word += text.charAt(pos);
				pos += 1;		
			}
			return word;
		}
		public function lastWordAfterPos(pos:int):String
		{			
			var word:String = '';
			pos = lastCharAtLinePos(pos);
			pos = trimPosLeft(pos);
			while(!text.charAt(pos).match(/\s/) && pos > -1) {
				word += text.charAt(pos);
				pos -= 1;		
			}
			return string_reverse(word);
		}
		
		public function string_reverse(s:String):String 
		{
			var r:String = '';
			for(var i:int = s.length; i >= 0; i -= 1) {
				r += s.charAt(i);
			}
			return r;		
		}
		
		public function deleteText(pos:uint, length:uint):void
		{
			var text:String = text.substr(pos, length);
			var ci:uint = tf.caretIndex;
			tf.replaceText(pos, pos + length, '');
			tf.dispatchEvent(new DeleteTextEvent(pos, text));
			tf.setSelection(ci - 1, ci - 1);
		}
		
		public function replaceText(pos:uint, length:uint, newText:String):void
		{
			var oldText:String = text.substr(pos, length);
			var ci:uint = tf.caretIndex;
			var diff:int = newText.length - oldText.length;
			ci += diff;
			tf.replaceText(pos, pos + length, newText);
			tf.setSelection(ci, ci);
			tf.dispatchEvent(new ReplaceEvent(pos, oldText, newText, [ci, ci]));
		}
		
		private function test(event:MouseEvent):void
		{
			var pos:int = tf.getCharIndexAtPoint(event.localX, event.localY);
			Alert.show(countCharsFromStart('\t',pos).toString());
		}
		
		private function tabLines(e:KeyboardEvent):void 
		{		
			this.setFocus();
			if(e.charCode == Keyboard.TAB){
				var selBegin:int = tf.selectionBeginIndex;
				var selEnd:int = tf.selectionEndIndex;
				var oldText:String = tf.text.substring(selBegin, selEnd);				
				var startLine:int = lineAtPos(selectionBeginIndex);
				var endLine:int = lineAtPos(tf.selectionEndIndex);
				var i:uint; 
				var pos:int;
				var newText:String;
				var newSelection:Array;
				var oldSelection:Array;
				var replacements:int = 0;
				
				if(text.length == 0) {
					pos = 0;
				} else {
					pos = tf.getLineOffset(startLine);	
				}
				
				if(!e.shiftKey) {
					if(tf.selectionBeginIndex != tf.selectionEndIndex) {
						newText = oldText.split('\r').map(function(el:String, ...params):String {
							replacements += 1;
							return '\t' + el;
						}).join('\n');
						newSelection = [pos, selEnd + replacements];
						tf.replaceText(selBegin, selEnd, newText);
						tf.dispatchEvent(new ReplaceSelectionEvent([selBegin, selEnd], oldText, newSelection, newText));
						tf.setSelection(newSelection[0], newSelection[1]);
					} else {
						insertAtCaretPos('\t');
					}				
				} else {					
					if(selBegin != selEnd) {
						newText = oldText.split('\r').map(function(el:String, ...params):String {
							if(el.substr(0, 1) == '\t') {
								replacements += 1;
								return el.substring(1, el.length);
							} else {
								return el;
							} 
						}).join('\n');
						newSelection = [pos, selEnd - replacements];
						tf.replaceText(selBegin, selEnd, newText);
						tf.dispatchEvent(new ReplaceSelectionEvent([selBegin, selEnd], oldText, newSelection, newText));
						tf.setSelection(newSelection[0], newSelection[1]);
					} else if(text.charAt(tf.caretIndex - 1) == '\t') {
						pos = tf.caretIndex - 1;
						tf.replaceText(pos, pos + 1, '');
						tf.dispatchEvent(new ReplaceSelectionEvent([pos, pos + 1], '\t', [pos, pos], ''));
						tf.setSelection(pos, pos);
					}
					
				}		
				callLater(setFocus);
			}
		}
		public function undo():void 
		{
			undoTF.undo(tf);			
		}
		
		public function redo():void
		{
			undoTF.redo(tf);
		}
		

		
		public function get numLines():uint 
		{
			return this.textField.numLines;
		}
		
		
	}
}