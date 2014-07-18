package pseudoglossa
{
	
	public class Token 
	{
		public var type:String;
		public var value:String;
		public var pos:uint;
		public var specKey:SpecKey;
		public var tokenIndex:uint;
		public var line:uint;
		public var key:String;
		public static var TERMINALS:Array = ['BOOLEAN', 'NAME', 'STRING', 'NUMBER', 'STANDARD_FUNCTION'];

		
		public function Token(type:String, value:String, pos:uint, tokenIndex:uint, line:uint)
		{
			this.type = type;
			this.value = value;
			this.key = value;
			this.pos = pos;
			this.tokenIndex = tokenIndex;
			this.line = line;
		}
		public function setSpecKey(sk:SpecKey):void 
		{
			specKey = sk;
			value = sk.value
			if(!key) key = sk.key; // for non word tokens newline sucks!
		}
		public function get length():uint
		{
			return key.length;
		}
		public function isName():Boolean
		{
			return type == 'NAME'  || type == 'STANDARD_FUNCTION';
		}
		public function isOperator():Boolean
		{
			return type == 'OPERATOR';
		}
		public function isTerminal():Boolean
		{
			return Token.TERMINALS.indexOf(type) > -1;
		}
		public function isStandardFunction():Boolean
		{
			return type == 'STANDARD_FUNCTION';
		}	
	}
}
