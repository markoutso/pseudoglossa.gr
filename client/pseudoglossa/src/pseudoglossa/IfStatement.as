package pseudoglossa
{
	public class IfStatement extends ContainerStatement
	{
		public var condition:Expression;
		public var hasElse:Boolean;
		public var elseStatements:Array;
		public var isSimple:Boolean;
		public var elseLine:uint;
		public var elseIfStatements:Array;
		public var executed:Boolean;
		
		public var nextIndex:uint;
		
		public function IfStatement(condition:Expression)
		{
			this.isSimple = false;
			this.hasElse = false;
			this.condition = condition;
			this.elseStatements = [];
			this.elseIfStatements = [];
			this.executed = false;
			this.desc = 'Αν';
		}
		
		public function jumpNext():void 
		{
			Environment.instance.setPC(nextIndex);
		}
		
		override public function createSteps():void 
		{
			setStartPos();
			condition.createSteps();
			Environment.instance.addCommand(function():void {
				if(!condition.value) {
					jumpNext();
				} else {
					Environment.instance.advancePC();
				}
			}, line);
			createChildrenSteps();
			if(!isSimple) {
				Environment.instance.addCommand(function():void{
					exit();
				}, endLine);
				nextIndex = Environment.instance.length;
				for each(var elseIf:ElseIfStatement in elseIfStatements) {
					elseIf.createSteps();
				}
				if(hasElse) {
					for each(var st:Statement in elseStatements) {
						st.createSteps();
					}
				}
				exitIndex = Environment.instance.length;
			}
		}

		public function setHasElse(line:uint):void 
		{
			hasElse = true;
			elseLine = line;
		}
	}
}

