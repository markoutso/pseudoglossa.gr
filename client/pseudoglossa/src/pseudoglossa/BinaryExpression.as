package pseudoglossa
{
	public class BinaryExpression extends Expression
	{
		public var exp1:Expression;
		public var exp2:Expression;
		public var operator:Operator;
		
		public function BinaryExpression(operator:Operator, exp1:Expression, exp2:Expression)
		{
			this.exp1 = exp1;
			this.exp2 = exp2;
			this.operator = operator;
		}

		override public function createSteps():void
		{
			exp1.createSteps();
			exp2.createSteps();
		}
		
		override public function get value():*
		{
			var ret:* = operator.compute(exp1.value, exp2.value);
			if(operator.type == 'ARITHMETIC') {
				if(!isFinite(ret) || isNaN(ret)) {					
					throw new PRuntimeError(PRuntimeError.ARITHMETIC_ERROR + ': ' + exp1.value + ' ' + operator.key + ' ' + exp2.value);
				}
			}
			return ret;
		}
	}
}