package pseudoglossa
{
	import flash.utils.getQualifiedClassName;

	public class AlgorithmSet
	{
		public var algorithms:Array;
		public var algTable:Object;
		
		public function AlgorithmSet(code:String)
		{
			this.algorithms = new Parser(new TokenList(new LexicalTokenizer(code))).parse();
			this.algTable = {};
		}
		
		public function getAlgorithm(name:String):AlgorithmStatement
		{
			return algTable[name];
		}
		
		public function createSteps():void
		{
			for each(var alg:AlgorithmStatement in algorithms) {
				alg.createSteps();
			}
		}
		
		public function prepare():void
		{
			var alg:AlgorithmStatement;
			for each(alg in algorithms) {
				algTable[alg.name] = alg;
			}
		}
		
		public function get main():AlgorithmStatement
		{
			return algorithms.length > 0 ? algorithms[0] : null;
		}
		
		public function check():void
		{	
			var alg:AlgorithmStatement;
			var h:Object = {};
			for each(alg in algorithms) {
				if(h.hasOwnProperty(alg.name)) {
					throw new PTypeError(PTypeError.DUPLICATE_ALGORITHM_DECLARATION, alg.line);
				} else {
					h[alg.name] = alg;
				}
			}
			Frame.reset();
			var frames:Array = [];
			for(var i:uint = 0; i < algorithms.length; i += 1) {
				frames.push(new Frame(this.algorithms[i]));
			}	
			
			for each(var frame:Frame in frames) {
				frame.checker.check();
			}		
			//see Checker::checkAlgorithmExpression
			for each(frame in frames) {
				frame.checker.check();
			}
			Frame.reset();
		}
	}
}