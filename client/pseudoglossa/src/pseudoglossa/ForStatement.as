package pseudoglossa
{	
	public class ForStatement extends ContainerStatement	
	{
		public var lvalue:LValue;
		public var start:Expression;
		public var end:Expression;
		public var step:Expression;
		
		//it differs in each stack frame
		public var varInitialised:Variable;
		
		public function ForStatement(lvalue:LValue)	
		{
			this.lvalue = lvalue;
			this.varInitialised = new Variable('$_for_' + index + '_varInitialised');
			this.desc = 'Για';
			
		}

		override public function createSteps():void 
		{			
			var jumpIndex:uint = Environment.instance.length;
			setStartPos();
			start.createSteps();
			end.createSteps();
			step.createSteps();
			varInitialised.value = false;
			Environment.instance.addCommand(function():void {
				if(!(varInitialised.isset && varInitialised.value)) {
					lvalue.value = start.value;
					varInitialised.value = true;
				}
				if(!evaluateCondition()){	
					varInitialised.value = false;			
					exit();
				}
				else {
					Environment.instance.advancePC();
				}
			}, line);			
			createChildrenSteps();
			Environment.instance.addCommand(function():void {
				lvalue.value += step.value;
				Environment.instance.setPC(jumpIndex);
			}, endLine);
			exitIndex = Environment.instance.length;
		}
		public function evaluateCondition():Boolean 
		{			
			var nStart:Number = lvalue.value;
			var nEnd:Number = end.value;
			var nStep:Number = step.value;
			var stepIsPositive:Boolean = nStep > 0;		
			
			if((nStart < nEnd && !stepIsPositive) || (nStart > nEnd && stepIsPositive)) {
				return false;
			}
			if(nStep == 0) {
				throw new PRuntimeError(PRuntimeError.ZERO_STEP, step.line);
			}							
			if(stepIsPositive) {
				return nStart <= nEnd;
			}
			else {
				return nStart >= nEnd;
			}			
		}
	}
}
