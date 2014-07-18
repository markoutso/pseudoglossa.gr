package pseudoglossa
{
	import mx.utils.ObjectUtil;

	public class Frame
	{
		public static var count:uint = 0;
		public static var frames:Object = {};
		
		public var nodeTable:NodeTable;
		public var algorithm:AlgorithmStatement;
		public var checker:Checker;
		public var paramTable:Object;
		public var caller:*;
		public var symbolTable:SymbolTable;
		public var index:uint;
		public var ntBuilder:NodeTableBuilder;
		
		public function Frame(alg:AlgorithmStatement, caller:* = null)
		{
			count += 1;
			if(!frames.hasOwnProperty(alg.name)) {
				frames[alg.name] = [];
			}
			frames[alg.name].push(this);
			
			this.nodeTable = new NodeTable(alg);
			this.ntBuilder = new NodeTableBuilder(alg, this.nodeTable);
			this.algorithm = alg;
			this.checker = new Checker(alg, this);
			this.paramTable = {};
			this.caller = caller;
			this.symbolTable = new SymbolTable();
			this.index = count;
			
			build();
			copyIn();
		}
		
		public static function reset():void
		{
			count = 0;
			frames = {};
		}
		
		public function get returnIndex():uint
		{
			return caller ? caller.returnIndex : 0;
		}
		
		public function build():void
		{
			this.ntBuilder.build();
			var all:Array = algorithm.data.params.concat(algorithm.results.params);
			if(caller && caller.params) {
				for(var i:uint = 0; i < caller.params.length; i += 1) {
					paramTable[all[i].name] = caller.params[i];
				}
			}
		}
		
		public function copyIn():void
		{
			var entry:ArrayStruct;
			if(caller && caller.params) {
				for each(var exp:Object in algorithm.data.params) {
					if(paramTable[exp.name] is ArrayStruct) {
						symbolTable.set(exp.name, ObjectUtil.copy(paramTable[exp.name].value));
					} else if (paramTable[exp.name] is LValue) {
						symbolTable.set(exp.name, paramTable[exp.name].value);
					} else { //constant or expression
						symbolTable.set(exp.name, paramTable[exp.name].value);
					}
				}
			}
		}
		
		public function copyOut():void
		{
			if(caller is CallStatement) {
				var callstat:CallStatement = caller as CallStatement;
				var cexp:*, rexp:*;
				for(var i:uint = 0; i < algorithm.results.params.length; i += 1) {
					rexp = algorithm.results.params[i];
					cexp =  Environment.instance.parentFrame.nodeTable.get(paramTable[rexp.name].name);
					Checker.setLValue(rexp, cexp, algorithm.name);
					rexp = algorithm.results.params[i];
					cexp =  Environment.instance.parentFrame.nodeTable.get(paramTable[rexp.name].name);
					Checker.setLValue(cexp, rexp, Environment.instance.parentFrame.algorithm.name);
					rexp = algorithm.results.params[i];
					cexp = Environment.instance.parentFrame.nodeTable.get(paramTable[rexp.name].name);
					
					if(cexp is ArrayStruct) {
						cexp.parentFrameValue = ObjectUtil.copy(rexp.value);
						cexp.elType = rexp.elType;
					} else if (cexp is LValue) {
						cexp.parentFrameValue = rexp.value;
						checker.setType(cexp, rexp.type);
					}
				}
			} else if(Environment.instance.frame.caller is AlgorithmExpression) {
				caller.parentFrameValue = algorithm.results.params[0].value;
			}
		}
	}
}