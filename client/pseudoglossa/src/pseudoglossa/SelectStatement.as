package pseudoglossa
{
	public class SelectStatement extends ContainerStatement
	{
		public var selector:Expression;
		public static const AUTO_BREAK:Boolean = true;
		public var caseExecuted:Boolean;
		public var selectorValue:Variable;
		
		public function SelectStatement() 
		{
			this.desc = 'Επίλεξε';
			this.selectorValue = new Variable('$_select_' + index +'_selectorValue');
		}

		override public function createSteps():void 
		{
			setStartPos();
			selector.createSteps();
			Environment.instance.addCommand(function():void {
				if(!selectorValue.isset) {
					selectorValue.value = selector.value;
				}
				Environment.instance.advancePC();
			}, line);
			createChildrenSteps();
			exitIndex = Environment.instance.length;
		}
	}
}