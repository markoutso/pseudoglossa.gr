package pseudoglossa
{
	public class UnaryExpression extends Expression
	{
		public var exp:Expression;
		public var operator:Operator;
		
		public function UnaryExpression(operator:Operator, argument:Expression)
		{
			this.operator = operator;
			this.exp = argument;
		}

		override public function createSteps():void
		{
			exp.createSteps();
		}
		
		override public function get value():*
		{
			var ret:* = operator.compute(exp.value);
			if(operator.type == 'ARITHMETIC') {
				if(!isFinite(ret) || isNaN(ret)) {
					throw new PRuntimeError(PRuntimeError.ARITHMETIC_ERROR + ': ' + operator.key + ' ' + exp.value);
				}
			}
			return ret;
		}
	}
}		