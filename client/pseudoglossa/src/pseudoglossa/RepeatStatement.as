package pseudoglossa
{
	public class RepeatStatement extends ContainerStatement
	{
		public var condition:Expression;
		
		public function RepeatStatement() 
		{
			this.desc = 'μέχρις_ότου';
		}
		
		override public function createSteps():void 
		{
			var obj:RepeatStatement = this;
			setStartPos();
			Environment.instance.addCommand(function():void {
				Environment.instance.advancePC();
			}, line);
			createChildrenSteps();
			condition.createSteps();
			Environment.instance.addCommand(function():void {
				if(obj.condition.value) {
					Environment.instance.advancePC();
				} else {
					Environment.instance.setPC(obj.startIndex);
				}
			}, endLine);
		}
	}
}