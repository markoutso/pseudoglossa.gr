package pseudoglossa
{
	public class ContainerStatement extends Statement 
	{
		public var statements:Array = [];		
		public var exitIndex:uint;
		
		public function ContainerStatement() 
		{
			
		}

		public function exit():void
		{
			Environment.instance.setPC(exitIndex);
		}
		
		public function createChildrenSteps():void 
		{
			for each(var st:Statement in statements) {
				st.createSteps();
			}
			exitIndex = Environment.instance.length;
		}
	}
}