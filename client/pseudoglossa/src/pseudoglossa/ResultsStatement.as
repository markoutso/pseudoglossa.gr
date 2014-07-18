package pseudoglossa
{
	public class ResultsStatement extends Statement 
	{
		public var params:Array;
		
		public function ResultsStatement()
		{
			this.params = [];
			desc = 'Αποτελέσματα';
		}

		override public function createSteps():void
		{
			if(params.length > 0) {
				Environment.instance.addCommand(function():void {
					if(Environment.instance.frame.returnIndex == 0) {
						var acc:Array = [];
						for each(var param:Expression in params) {
							acc.push(param.printVal);
						}
						Environment.instance.results(acc.join('\r'));
					}
					Environment.instance.advancePC();
				}, line);
			}
		}
	}
}