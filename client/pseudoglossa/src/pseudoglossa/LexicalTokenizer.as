package pseudoglossa
{		
	public class LexicalTokenizer
	{
		private var currentPos:uint;
		private var previousPos:uint;
		private var markPos:uint;
		private var currentTokenPos:uint;
		private var buffer:String;
		private var tokenIndex:uint;
		private var currentLine:uint;
		private var length:uint;
		private var continueOnError:Boolean;
		private var inComment:Boolean;
		private var curComment:String;
		
		private var lineIndexes:Array;
		
		
		public static const MODE_HIGHLIGHT:Boolean = false;
		public static const MODE_COMPILE:Boolean = true;
		
		public function LexicalTokenizer(code:String, cont:Boolean = LexicalTokenizer.MODE_COMPILE)
		{			
			this.continueOnError = cont;			
			this.initMembers(code);
		}
		public function reset(code:String):LexicalTokenizer 
		{
			initMembers(code);
			return this;
		}
		private function initMembers(code:String):LexicalTokenizer
		{
			this.currentPos = 0;
			this.previousPos = 0;
			this.markPos = 0;
			this.currentTokenPos = 0;
			this.markPos = 0;
			this.buffer = code;
			this.length = this.buffer.length;
			this.tokenIndex = 0;
			this.currentLine = 1;
			this.inComment = false;	
			this.lineIndexes = [];
			return this;
		}
		public function getCurrentPos():uint
		{
			return currentPos;
		}
		public function setCurrentPos(pos:uint):void
		{
			currentPos = pos;
		}
		public function getPreviousPos():uint
		{
			return previousPos;
		}
		public function hasMoreTokens():Boolean
		{
			return currentPos < length;
		}
		public function getBuffer(posFrom:uint, length:uint):String 
		{
			return buffer.substr(posFrom, length);	
		}
		public function getLength():uint 
		{
			return length;
		}
		public function mark():LexicalTokenizer
		{
			markPos = currentPos;
			return this;
		}
		public function step(n:uint = 1):LexicalTokenizer 
		{
			currentPos += n;		
			return this;	
		}
		public function resetToMark():LexicalTokenizer
		{
			currentPos = markPos;
			return this;
		}
		public function check(s:String):Boolean 
		{
			for(var i:uint = 0; i < s.length; i++) {
				if(s.charAt(i) != buffer.charAt(currentPos + i)) {
					return false;
				}
			}
			return true;
		}
		public function look(n:uint = 0, abs:Boolean = false):String 
		{
			var pos:uint = abs ? n : currentPos + n;
			return buffer.charAt(pos);
		}
		
		private function tokenFromSpecKey(specKey:SpecKey, key:String = ''):Token 
		{
			var t:Token;
			var name:String;
			if(specKey.category == 'OPERATORS') 
				name = 'OPERATOR';
			else if(specKey.category == 'SYMBOLS') 
				name = 'SYMBOL';
			else if(specKey.category == 'FUNCTIONS') 
				name = 'STANDARD_FUNCTION';
			else if(specKey.category == 'KEYWORDS') 
				name = 'KEYWORD';
			else if(specKey.category == 'BOOLEAN')
				name = 'BOOLEAN';
			else if(specKey.category == 'EOL')
				name = 'EOL';
			var k:String = key ? key : specKey.value;
			t = new Token(name, key, currentTokenPos, tokenIndex, currentLine);
			t.setSpecKey(specKey);
			return t;
		}
		
		public function parseWord():Token 
		{
			var s:String = '';
			while(hasMoreTokens() && Spec.isWordChar(look())) {
				s += look();
				step();
			}
			//correct letter case...plus plus
			var sN:String = Spec.normaliseGreek(s.toLowerCase());			
			if(Spec.hasKey(sN, true)) {				
				return tokenFromSpecKey(Spec.getKey(sN, true), s);
			} else {
				return new Token('NAME', s, currentTokenPos, tokenIndex, currentLine);
			}
		}
		
		private function ignoreSpaces():LexicalTokenizer
		{
			while(hasMoreTokens() && Character.isSpace(look()) &&
				!Character.isNewLine(look())) {
				step();
			}
			return this;
		}
		private function ignoreComments():LexicalTokenizer
		{
			curComment = '!';
			step();
			while(hasMoreTokens() && !Character.isNewLine(look())) {				
				curComment += look();
				step();
			}
			return this;
		}
		private function parseUnknown(s:String = ''):Token 
		{
			while(hasMoreTokens() && !Character.isSpace(look())) {
				s += look();
				step();
			}
			return new Token('UNKNOWN', s, currentTokenPos, tokenIndex, currentLine);
		}
		private function parseAlphaNumericConstant():Token 
		{
			var quote:String = look();
			var s:String = quote;
			while(hasMoreTokens()) {
				step();
				if(Character.isNewLine(look())) {
					if(continueOnError) {
						throw new LexError(LexError.EXPECTED_END_OF_QUOTE + quote, currentLine);
					} else {
						return new Token('UNFINISHED_STRING', s, currentTokenPos, tokenIndex, currentLine);
					}					
				} else if(look() == quote) {
					if(look(1) == quote) {
						step();
					} else {
						step();
						s += quote;
						return new Token('STRING', s, currentTokenPos, tokenIndex, currentLine);
					}
				} else {
					s += look();
				}
			}
			if(continueOnError) {
				throw new LexError(LexError.EXPECTED_END_OF_QUOTE + quote, currentLine);
			} else {
				return new Token('UNFINISHED_STRING', s, currentTokenPos, tokenIndex, currentLine);
			}
		}
		
		public function nextToken():Token{
			tokenIndex += 1;
			previousPos = currentPos;
			ignoreSpaces();
			currentTokenPos = currentPos;
			inComment = false;			
			
			while(Spec.isLineComment(look())) {
				inComment = true;				
				ignoreComments();
				/*if(hasMoreTokens()) {
					currentLine++;
				}*/
				if(!continueOnError) {
					return new Token('COMMENT', curComment, currentTokenPos, tokenIndex, currentLine);
				}				
			}			
			if(inComment) {				
				return new Token('EOL', '@EOL', currentTokenPos, tokenIndex, currentLine);				
			}
			if(currentPos >= length) {
				return new Token('EOF', '@EOF', currentTokenPos, tokenIndex, currentLine);
			}
			
			var s:String = look();
			if(Spec.hasNonWord(s)) {				
				var token:* = parseNonWord();
				if(token is Token) {
					if(token.value == '@EOL') {
						currentLine++;
					}
					return token;
				}
			}
			if(Character.isDigit(s)) {
				return parseNumericConstant();
			} else if(Spec.isQuote(s)) {
				return parseAlphaNumericConstant();
			}
			if(!Character.isLetter(s)) {
				if(continueOnError) {
					throw new LexError(LexError.INVALID_INPUT, currentLine);
				} else {
					return parseUnknown();
				}
			}
			return parseWord();
		}
		
		private function parseNonWord():Object {
			var s:String = look();
			var i:uint = 1;
			var hasKeys:Boolean = true;
			var keys:Array = Spec.getNonWord(s);
			while(hasKeys && keys.length > 1 && (currentPos + i < length)) {
				s += look(i++);
				hasKeys = Spec.hasNonWord(s);
				keys = Spec.getNonWord(s);
			}			
			if(hasKeys && (keys.length == 1 || s.length == 1)) {
				var s1:String = keys[0];
				if(s1.length > 1) {
					if(check(s1)){
						step(s1.length);						
						return tokenFromSpecKey(Spec.getKey(s1));						
					} else {
						return false;
					}
				} else {
					step();
					return tokenFromSpecKey(Spec.getKey(s));
				}
			} else {
				do {				
					s = s.substr(0, s.length - 1);
					i--;
					keys = Spec.getNonWord(s);
					for each(var v:String in keys){
						if(s == v) {
							step(i);
							return tokenFromSpecKey(Spec.getKey(s));
						}
					} 
				}while(keys.length > 1);
			}
			return false;
		}
		
		private function parseNumericConstant():Token {
			var n:String = '';
			while(hasMoreTokens() && Character.isDigit(look())) {
				n += look();
				step();
			}
			var type:String = 'NUMBER';
			var parsedReal:Boolean;
			if(Spec.isDecimalSymbol(look())){
				// 1..2 επίλεξε
				if(!Spec.isDecimalSymbol(look(1))) {
					n += Spec.DECIMAL_SYMBOL;
					step();
					parsedReal = false;
					while(hasMoreTokens() && Character.isDigit(look())) {
						parsedReal = true;
						n += look();
						step();
					}
					if(!parsedReal) {
						if(continueOnError){
							throw new LexError(LexError.ERROR_PARSING_NUMBER, currentLine);
						} else {
							return parseUnknown(n);
						}
					}
				} else {
					return new Token(type, n, currentTokenPos, tokenIndex, currentLine);
				}
			}
			if(!Spec.isWordChar(look())){				
				return new Token(type, n, currentTokenPos, tokenIndex, currentLine);
			} else {
				if(continueOnError){
					throw new LexError(LexError.ERROR_PARSING_NUMBER, currentLine);
				} else {
					return new Token(type, n, currentTokenPos, tokenIndex, currentLine);
				}				
			}
		}
	}
}