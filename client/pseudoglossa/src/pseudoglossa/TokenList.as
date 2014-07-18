package pseudoglossa
{
	public class TokenList 
	{
		private var tokens:Array;
		private var lt:LexicalTokenizer;
		private var ptr:int;
		private var first:Boolean;

		public static const CHUNK_SIZE:uint = 250;

		public function TokenList(lt:LexicalTokenizer)
		{
			this.lt = lt;
			this.tokens = [];
			this.ptr = -1;
		}
		public function getList():Array
		{
			var list:Array = [];
			while(hasNext()){
				list.push(next());
			}
			return list;
		}
		public function getChunk():Array
		{
			var list:Array = [];
			var t:Token;
			var found:Boolean = false;
			var pos:int = lt.getCurrentPos();
			while(hasNext() && !found && (lt.getCurrentPos() - pos < CHUNK_SIZE)) {
				t = next();
				list.push(t);
				found = t.value == '@EOL';
			}
			return list;
		}
		public function getArea(start:uint, end:uint):Array
		{
			var list:Array = [];
			var t:Token;
			lt.setCurrentPos(start);
			while(hasNext() && (lt.getCurrentPos() < end)) {
				t = next();
				list.push(t);
			}
			return list;
		}
		public function hasNext():Boolean
		{
			return (lt.hasMoreTokens()) || (ptr < tokens.length -1);
		}
		public function next():Token 
		{
			if(ptr < tokens.length - 1) {
				ptr++;
				return tokens[ptr];
			} else {
				appendFromLt();
				ptr++;
				return tokens[ptr];
			}
		}
		
		public function peek(n:uint):Token
		{
			for(var i:uint = 0; i < n; i += 1) {
				if(lt.hasMoreTokens()) {
					appendFromLt();
				} else {
					return null;
				}
			}
			return tokens[ptr + n];
		}
		
		public function hasPrevious():Boolean 
		{
			return ptr > 0;			
		}
		public function previous():Token 
		{
			ptr--;
			return tokens[ptr];
		}
		private function appendFromLt():void
		{
			tokens.push(lt.nextToken());
		}
		public function current():Token
		{
			return tokens[ptr];
		}
		
		public function getAreaLength(from:uint):uint
		{
			var token:Token = tokens[ptr];
			var s:String = token.specKey ? token.specKey.key : token.value;
			var length:uint = token.pos + s.length - from;
			return length;  
		}
	}
}