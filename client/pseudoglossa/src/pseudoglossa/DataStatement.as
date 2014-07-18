package pseudoglossa
{
	public class DataStatement extends Statement
	{
		public var params:Array;
		public var dataIndex:Variable;
		
		public function DataStatement()
		{
			this.params = [];
			this.desc = 'Δεδομένα';
			this.dataIndex = new Variable('$_data_' + index + '_dataIndex');
		}

		override public function createSteps():void
		{
			var that:DataStatement = this;
			dataIndex.value = 0;
			if(params.length > 0) {
				Environment.instance.addCommand(function():void {
					if(Environment.instance.frame.returnIndex == 0) {
						if(!dataIndex.isset) {
							dataIndex.value = 0;
						}
						var lv:LValue = params[dataIndex.value];
						Environment.instance.halt();
						Environment.instance.inputData(setInput, lv);
					} else {
						Environment.instance.advancePC();
					}
				}, line);
			}
		}

		public function setInput(value:*):void
		{
			var l:LValue = params[dataIndex.value],
				type:String, checkType:String;
			if(typeof value == 'string') {
				type = Checker.guessType(value);
				if(!Checker.areComp(l.type, type)) {
					Environment.instance.handleRuntimeError(new PRuntimeError(PRuntimeError.ILLEGAL_TYPE_READ), line);
					return;
				}
			} else {
				for(var k:String in value) {
					type = Checker.guessType(value[k]);
					checkType = l is ArrayStruct ? ArrayStruct(l).elType : l.type;
					if(!Checker.areComp(checkType, type)) {
						Environment.instance.handleRuntimeError(new PRuntimeError(PRuntimeError.ILLEGAL_TYPE_READ), line);
						return;
					}
				}
			}
			if(type != 'VARIABLE') { 
				Environment.instance.frame.checker.setType(l, type);
			} 
			l.valueFromInput = value;
			dataIndex.value += 1;
			if(dataIndex.value == params.length) {
				Environment.instance.advancePC();
				dataIndex.value = 0;
			}
			Environment.instance.resume();
		}
	}
}
