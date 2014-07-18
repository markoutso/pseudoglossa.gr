package pseudoglossa
{
	import flight.utils.Type;

	public class LValue extends Expression 
	{		
		public var _name:String;
		
		public function LValue(name:String)
		{
			this._name = name;
			this._type = 'LVALUE';
		}
		
		public function toSingleValued(t:String):*
		{
			var ret:Variable = new Variable(_name);
			ret.type = t;
			ret.setLocation(from, length, line);
			return ret;
		}
		
		public function toArray(arr:ArrayStruct = null):ArrayStruct
		{
			var a:ArrayStruct = new ArrayStruct(_name);
			a.setLocation(from, length, line);
			if(arr) {
				a.dimension = arr.dimension;
			}
			return a;
		}
		
		public function get name():String
		{
			return _name;
		}
	
		public function set name(n:String):void
		{
			_name = n;
		}
		
		override public function get value():*
		{
			throw new PRuntimeError(PRuntimeError.UNKNOWN_TYPE + ' για το όνομα ' + name, line);
		}
		
		public function set value(v:*):void
		{
			throw new Error('abstract class error');	
		}
		
		public function get parentFrameValue():*
		{
			return Environment.instance.parentFrame.symbolTable.get(name);
		}
		
		public function set parentFrameValue(v:*):void
		{
			Environment.instance.parentFrame.symbolTable.set(name, v);
		}
		
		public function set valueFromInput(v:*):void
		{
			throw new Error('abstract class error');
		}
	}
}