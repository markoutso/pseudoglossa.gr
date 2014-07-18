package pseudoglossa
{	
/*
 15..20
 >3 
 5+A+Τ_Ρ(3) --normal
*/
	public class CaseExpression  extends Expression
	{
		public var operator:Operator;
		public var exp1:Expression;
		public var exp2:Expression;
		public var isElse:Boolean;
		public var caseStatement:CaseStatement;
		public var isOpCase:Boolean;
		
		public function CaseExpression(exp1:Expression, operator:Operator=null, exp2:Expression=null)
		{
			if (exp1.value == '@ELSE') {
				this.isElse = true;
			} else {
				this.isElse = false;
			}
			this.operator = operator;
			this.exp1 = exp1;
			this.exp2 = exp2;
			if(this.operator && this.operator.value != 'CASE_OP') {
				this.isOpCase = false;
			}
			else if(this.operator) {
				this.isOpCase = true;
			}
		}

		override public function createSteps():void
		{
			if(isElse) {
				return;
			}
			exp1.createSteps();
			if(exp2) {
				exp2.createSteps();
			} 
		}
		
		override public function get value():*
		{
			if(isElse) { 
				return true;
			}
			if(isOpCase) {
				var n:Number = caseStatement.select.selectorValue.value;
				if(n >= exp1.value && n <= exp2.value) {
					return true;
				} 
				else {
					return false;
				}
			}			
			if(operator) {
				return operator.compute(caseStatement.select.selectorValue.value, exp1.value);
			}
			else {
				return exp1.value == caseStatement.select.selectorValue.value;
			}
		}
		
		public function setCaseStatement(caseStatement:CaseStatement):void {
			this.caseStatement = caseStatement;
			caseStatement.expressions.push(this);
		}
	}
}

