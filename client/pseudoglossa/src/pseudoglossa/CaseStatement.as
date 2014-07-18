package pseudoglossa
{
	public class CaseStatement extends ContainerStatement 
	{
		public var expressions:Array;
		public var select:SelectStatement;
		
		public var nextIndex:uint;
		
		public function CaseStatement(select:SelectStatement)
		{
			this.expressions = [];
			this.select = select;
			this.desc = 'Περίπτωση';
		}
		
		override public function exit():void
		{
			Environment.instance.setPC(select.exitIndex);
		}

		public function jumpNext():void 
		{
			Environment.instance.setPC(nextIndex);
		}
		
		override public function createSteps():void 
		{
			for each(var exp:Expression in expressions) {
				exp.createSteps();
			}
			setStartPos();
			Environment.instance.addCommand(function():void {
				if(isToExecute()) {
					select.selectorValue.del();
					Environment.instance.advancePC();
				}
				else {
					jumpNext();
				}
			}, line);
			createChildrenSteps();
			nextIndex = Environment.instance.length + 1;
			Environment.instance.addCommand(function():void {
				exit();
			}, select.endLine);	
		}
		
		public function isToExecute():Boolean 
		{
			if(select.caseExecuted) {
				return false;
			}
			for each(var ce:CaseExpression in expressions) {
				if(ce.value) {
					return true;
				}
			}
			return false;
		}
	}
}
