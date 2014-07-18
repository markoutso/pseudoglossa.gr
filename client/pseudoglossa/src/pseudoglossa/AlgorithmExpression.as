package pseudoglossa
{
	public class AlgorithmExpression extends Expression
	{
		public var algorithm:AlgorithmStatement;
		public var params:Array;
		public var returnIndex:uint;
		
		public static var counter:uint = 0;
		
		private var _val:Variable;
		
		public function AlgorithmExpression(algorithm:AlgorithmStatement, params:Array) 
		{
			this.algorithm = algorithm;
			this.params = params || [];
			this._val = new Variable('$_algexpr_' + counter);
			counter += 1;
		}
		
		public function set value(v:*):void
		{
			_val.value = v;
		}
		
		override public function get value():*
		{
			return _val.value;
		}
		
		public function set parentFrameValue(v:*):void
		{
			_val.parentFrameValue = v;
		}
		
		override public function get type():String
		{
			//workaround
			// standardfunction expressions are algorithmexpressions in the first pass of the nodetablebuilder
			try {
				return algorithm.type;
			} catch(e:Error) {
				var sf:StandardFunction = StandardFunction.getStandardFunction(algorithm.name);
				if(sf) {
					return sf.type;
				}
			}
			return 'VARIANT';
		}
		
		public function updateParam(name:String, value:*):void
		{
			for(var i:uint = 0; i < params.length; i += 1) {
				if(params[i] is LValue && params[i].name == name) {
					params[i] = value;
				}
			}
		}
		
		override public function createSteps():void
		{
			var that:AlgorithmExpression = this;
			for each(var exp:Expression in params) {
				exp.createSteps();
			}
			Environment.instance.addCommand(function():void {
				Environment.instance.advancePC();
				returnIndex = Environment.instance.pc + 1; 
				Environment.instance.call(new Frame(algorithm, that));
			}, line);
			Environment.instance.addCommand(function():void {
			}, algorithm.line);
		}
	}
}