package pseudoglossa
{
	public class ClsStatement extends Statement
	{
		public function ClsStatement(line:uint=0)
		{
			this.desc = 'CLS';
		}
		
		override public function createSteps():void 
		{
			Environment.instance.addCommand(function():void {
				Environment.instance.systemOut.clear();
				Environment.instance.advancePC();
			}, line);	
		}
	}
}