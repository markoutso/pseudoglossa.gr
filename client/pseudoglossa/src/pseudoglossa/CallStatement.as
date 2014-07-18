package pseudoglossa
{
	public class CallStatement extends Statement
	{
		public var exp:AlgorithmExpression;
		public var returnIndex:uint;
		
		public function CallStatement(exp:AlgorithmExpression)
		{
			this.exp = exp;
			this.desc = 'Κάλεσε';
		}

		public function get params():Array
		{
			return exp.params;
		}
		
		override public function createSteps():void
		{
			var that:CallStatement = this;
			for each(var e:Expression in exp.params) {
				e.createSteps();
			}
			Environment.instance.addCommand(function():void {
				Environment.instance.advancePC();
				returnIndex = Environment.instance.pc + 1; 
				Environment.instance.call(new Frame(exp.algorithm, that));
			}, line);
			Environment.instance.addCommand(function():void {
			}, exp.algorithm.line);
		}
	}
}