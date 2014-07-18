package pseudoglossa	
{
	public class WriteStatement extends Statement
	{
		public var params:Array;
		
		public function WriteStatement()
		{
			this.params = [];
			this.desc = 'Εμφάνισε/Γράψε/Εκτύπωσε';
		}

		override public function createSteps():void
		{
			for each(var exp:Expression in params) {
				exp.createSteps();
			}
			Environment.instance.addCommand(function():void {
				var arr:Array = [];
				for each(var param:Expression in params) {
					arr.push(param.printVal);
				}
				Environment.instance.output(arr.join(' '));
				Environment.instance.advancePC();
			}, line);
			
		}
	}
}