package pseudoglossa
{	
	public class ElseIfStatement extends ContainerStatement
	{
		public var condition:Expression;
		public var ifStatement:IfStatement;
		
		public function ElseIfStatement(condition:Expression, ifStatement:IfStatement)
		{
			this.ifStatement = ifStatement;
			this.condition = condition;
			this.desc = 'αλλιώς_αν';
		}
		
		public function jumpNext():void 
		{
			Environment.instance.setPC(exitIndex);
		}
		
		override public function createSteps():void
		{
			setStartPos();
			condition.createSteps();
			Environment.instance.addCommand(function():void {
				if(!condition.value) {
					jumpNext();
				}
				else {
					Environment.instance.advancePC();
				}
			}, line);
			createChildrenSteps();
			Environment.instance.addCommand(function():void {
				ifStatement.exit();
			}, ifStatement.endLine);
			exitIndex = Environment.instance.length;
		}	
	}
}
