package pseudoglossa
{
	public class Statement 
	{
		public static var counter:uint = 0;
		
		public var line:uint;
		public var endLine:uint;
		public var startIndex:uint;
		public var desc:String;
		public var _index:String;
		
		
		public function Statement(line:uint = 0)
		{
			this.line = line;
			this.endLine = line;
			this.desc = 'Εντολή'; 
		}
		
		public function get env():Environment
		{
			return Environment.instance;
		}
		
		public function get index():String
		{
			if(!_index) {
				counter += 1;
				_index = String(counter);
			}
			return _index;
		}
		
		public function setStartPos():void 
		{
			startIndex = Environment.instance.length;			
		}
		
		public function createSteps():void 
		{
			Environment.instance.addCommand(function():void {
				execute();
				Environment.instance.advancePC();
			}, line);
		}
		public function execute():void
		{
			throw new Error('Abstract class Statement  invocation');
		}
	}
}