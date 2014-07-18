package pseudoglossa
{
	public class Variable extends LValue
	{
		public function Variable(name:String)
		{
			super(name);
			this.type = 'VARIABLE';
		}
		
		override public function toSingleValued(t:String):*
		{
			if(!Checker.areComp(type, t)) {
				throw new PTypeError(PTypeError.VARIABLE_TYPE_MISMATCH, line);
			}
			return this;
		}
		
		public function toBaseLValue():LValue
		{
			var l:LValue = new LValue(_name);
			l.setLocation(from, length, line);
			return l;
		}
		
		override public function toArray(arr:ArrayStruct = null):ArrayStruct
		{
			throw new PTypeError(PTypeError.EXPRESSION_NOT_ARRAY, line);
		}
		
		public function get isset():Boolean
		{
			return Environment.instance.frame.symbolTable.has(name);
		}
		
		override public function set value(v:*):void
		{
			Environment.instance.frame.symbolTable.set(name, v);
		}
		
		override public function set valueFromInput(v:*):void
		{
			if(type == 'STRING') {
				Environment.instance.frame.symbolTable.set(name, v);
			} else if (type == 'BOOLEAN') {
				Environment.instance.frame.symbolTable.set(name, Boolean(v));
			} else {
				Environment.instance.frame.symbolTable.set(name, Number(v));
			}
		}
		
		public function del():void
		{
			Environment.instance.frame.symbolTable.del(name);
		}
		
		override public function get value():*
		{
			var v:* = Environment.instance.frame.symbolTable.get(name);
			if(v == null) {
				throw new PRuntimeError(PRuntimeError.VARIABLE_NOT_INITIALISED + ' : ' + name, line);
			}
			return v;
		}
	}
}

	
