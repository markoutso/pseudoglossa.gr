package pseudoglossa
{	
	public class AlgorithmStatement extends ContainerStatement
	{
		public var name:String;
		
		public function AlgorithmStatement(name:String)
		{
			this.name = name;
			this.desc = 'Αλγόριθμος';
		}
		
		public function get type():String
		{
			if(results.params.length > 0) {
				return results.params[0].type;
			} else {
				return 'VOID';
			}
		}
		
		public function outParamIndexes():Array
		{
			var dl:uint = data.params.length,
				indexes:Array = [], i:uint, j:uint, found:Boolean, count:uint = 0;
			for (i = 0; i < results.params.length; i += 1) {
				found = false;
				for (j = 0;	j < dl; j += 1) {
					if(results.params[i].name == data.params[j].name) {
						count += 1;
						found = true;
						indexes.push(j);
					}
				}
				if(!found) {
					indexes.push(dl + i - count);
				}
			}
			return indexes;
		}	
		
		public function get data():DataStatement
		{
			return statements[0] as DataStatement;
		}
		
		public function get results():ResultsStatement
		{
			return statements[statements.length - 1];
		}

		override public function createSteps():void 
		{
			setStartPos();
			Environment.instance.addCommand(function():void {
				Environment.instance.advancePC();
			}, line);
			createChildrenSteps();
			if(Environment.instance.frame.caller) {
				Environment.instance.addCommand(function():void {
					Environment.instance.advancePC();
				}, Environment.instance.lines[Environment.instance.frame.returnIndex]);
			}
			Environment.instance.addCommand(function():void {
				Environment.instance.ret();
			}, endLine);
		}
	}
}
