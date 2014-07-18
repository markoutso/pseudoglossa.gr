package pseudoglossa
{
	public class Expression
	{
		public var _type:String = 'VARIABLE';
		
		public var from:uint;
		public var length:uint;
		public var line:uint;
		
		public function get type():String
		{
			return _type;
		}
		
		public function set type(type:String):void
		{
			_type = type;
		}
		
		public function get value():* 
		{
			throw new Error('abstract class error');
		}
		
		public function get printVal():String
		{
			if(type == 'BOOLEAN') {
				return	value == true ? Spec.CTRUE : Spec.CFALSE; 
			}
			return value;
		}

		public function createSteps():void
		{
			
		}
		
		public function setLocation(from:uint, length:uint, line:uint):void 
		{
			this.from = from;
			this.length = length;
			this.line = line;
		}
	}
}
