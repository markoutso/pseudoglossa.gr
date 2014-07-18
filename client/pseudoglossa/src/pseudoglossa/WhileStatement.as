package pseudoglossa
{
	public class WhileStatement extends ContainerStatement
	{
		public var condition:Expression;
		
		public function WhileStatement(condition:Expression)	
		{
			this.condition = condition;
			this.desc = 'Όσο';
		}

		override public function createSteps():void
		{
			setStartPos();
			condition.createSteps();
			Environment.instance.addCommand(function():void {
				if(!condition.value) {
					exit();
				}
				else {
					Environment.instance.advancePC();
				}
			}, line);
			createChildrenSteps();
			Environment.instance.addCommand(function():void {
				Environment.instance.setPC(startIndex);
			}, endLine);
			exitIndex = Environment.instance.length;
		}
	}
}