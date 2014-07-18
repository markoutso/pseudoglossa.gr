package pseudoglossa
{
	public class StandardFunctionExpression extends Expression
	{
		public var standardFunction:StandardFunction;
		public var params:Array;
		
		public function StandardFunctionExpression(func:StandardFunction, params:Array) 
		{
			this.standardFunction = func;
			this.params = params || [];
		}
		
		override public function get value():*
		{
			var p:Array = [], ret:*;
			for each(var exp:Expression in params) {
				p.push(exp.value);
			}
			
			try {
				ret = standardFunction.compute(p);
			} catch(e:Error) {
				throw new PRuntimeError(e.message, line);
			}
			if(standardFunction.type == 'NUMBER') {
				if(!isFinite(ret) || isNaN(ret)) {
					throw new PRuntimeError(PRuntimeError.INTERNAL_FUNCTION_ERROR, line);
				}
			}
			return ret;
		}
		
		override public function get type():String
		{
			return standardFunction.type;
		}
	}
}