package pseudoglossa
{
	public class ArrayElementExpression extends LValue
	{
		public var arrayStruct:ArrayStruct;
		public var params:Array;
		
		public function ArrayElementExpression(array:ArrayStruct, params:Array)
		{
			super(array.name);
			this.arrayStruct = array;
			this.params = params || [];
		}

		override public function toSingleValued(t:String):*
		{
			return this;
		}
		
		override public function toArray(arr:ArrayStruct = null):ArrayStruct
		{
			throw new PTypeError(PTypeError.EXPRESSION_NOT_ARRAY, line);
		}
		
		public function indexes():Array
		{
			var indexes:Array = [], val:*;
			for each(var exp:Expression in params) {
				val = exp.value;
				if(val != int(val) || val < 1) {
					throw new PRuntimeError(PTypeError.ARRAY_INVALID_INDEX, line);
				}
				indexes.push(exp.value);
			}
			return indexes;
		}
		
		override public function createSteps():void
		{
			for each(var exp:Expression in params) {
				exp.createSteps();
			}
		}
		
		override public function get parentFrameValue():*
		{
			return arrayStruct.getParentFrameEl(indexes());
		}
		
		override public function set parentFrameValue(v:*):void
		{
			arrayStruct.setParentFrameEl(indexes(), v);
		}
		
		override public function set value(v:*):void 
		{
			arrayStruct.setElValue(indexes(), v);
		}
		
		override public function set valueFromInput(v:*):void
		{
			arrayStruct.setElFromInput(indexes(), v);
		}
		 
		override public function get value():*
		{
			var ret:* = arrayStruct.getEl(indexes());
			if(ret == null) {
				throw new PRuntimeError(PRuntimeError.VARIABLE_NOT_INITIALISED + ': ' + arrayStruct.name + arrayStruct.key(indexes()), line);
			}		
			return ret;
		}
		
		override public function get type():String
		{
			return this.arrayStruct.elType;
		}
		
		override public function set type(type:String):void
		{
			this.arrayStruct.elType = type;
		}
		
		override public function get name():String
		{
			return this.arrayStruct.name;
		}
	}
}