package pseudoglossa
{
	public class ReadStatement extends Statement	
	{
		public var params:Array;
		public var readIndex:Variable;
		
		public function ReadStatement()
		{
			this.params = [];
			this.readIndex = new Variable('$_read_' + index +'_readIndex');
			this.desc = 'Διάβασε';
		}
		

		override public function createSteps():void 
		{
			Environment.instance.addCommand(function():void	{
				if(!readIndex.isset) {
					readIndex.value = 0;
				}
				var l:LValue = params[readIndex.value];
				 
				if(l.type == 'BOOLEAN') {
					throw new PRuntimeError(PRuntimeError.BOOLEAN_VARIABLE_READ, line);
				}
				Environment.instance.halt();
				Environment.instance.input(setInput, l);
			}, line);
		}
		public function setInput(value:String):void 
		{
			var l:LValue = params[readIndex.value];
			var type:String = Checker.guessType(value);
			if(!Checker.areComp(l.type, type)) {
				Environment.instance.handleError(new PRuntimeError(PRuntimeError.ILLEGAL_TYPE_READ), line);
				return;
			}
			if(type != 'VARIABLE') { 
				Environment.instance.frame.checker.setType(l, type);
			} 
			l.valueFromInput = value;
			readIndex.value += 1;
			if(readIndex.value == params.length) {
				Environment.instance.advancePC();
				readIndex.value = 0;
			}
			Environment.instance.resume();
		}
	}
}

