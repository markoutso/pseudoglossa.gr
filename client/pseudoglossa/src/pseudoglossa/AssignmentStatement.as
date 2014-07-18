package pseudoglossa
{
	public class AssignmentStatement extends Statement 
	{
		public var expression:Expression;
		public var lvalue:LValue;
		
		public function AssignmentStatement(lvalue:LValue)
		{
			this.lvalue = lvalue;
			this.desc = '<-';
		}

		override public function createSteps():void
		{
			lvalue.createSteps();
			expression.createSteps();
			Environment.instance.addCommand(function():void {
				lvalue.value = expression.value;
				Environment.instance.advancePC();
			}, line);
			
		}
	}
}
