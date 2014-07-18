package pseudoglossa
{
	public class SwapStatement extends Statement
	{
		public var lvalue1:LValue;
		public var lvalue2:LValue;
		
		public function SwapStatement()
		{
			this.desc = 'Αντιμετάθεσε';
		}
		
		override public function createSteps():void {
			lvalue1.createSteps();
			lvalue2.createSteps();
			Environment.instance.addCommand(function():void {
				var temp:* = lvalue1.value;
				lvalue1.value = lvalue2.value;
				lvalue2.value = temp;
				Environment.instance.advancePC();
			}, line);
			
		}
	}
}