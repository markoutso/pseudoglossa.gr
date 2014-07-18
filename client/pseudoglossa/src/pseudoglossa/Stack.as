package pseudoglossa
{
	public class Stack {
		public var arr:Array;
		
		public function Stack()	
		{
			this.arr = [];
		}
		
		public function getItemAt(pos:uint):*
		{
			if(pos >= length) {
				throw new Error('invalid position');
			} else {
				return arr[pos];
			}
		}
		
		public function get length():uint 
		{
			return arr.length;
		}
		
		public function reset():void 
		{
			arr = null;
			arr = [];
		}
		
		public function push(element:*):void 
		{
			arr.push(element);
		}
		
		public function pop():*
		{
			if(arr.length == 0) {
				throw new Error('Could not pop element');
			} 
			return arr.pop();
		}
		
		public function get top():Object 
		{
			if(arr.length == 0) {
				throw new Error('Could not top element');
			}
			return arr[arr.length - 1];
		}
 		public function isEmpty():Boolean
		{
			return arr.length == 0;
		}
	}
}
