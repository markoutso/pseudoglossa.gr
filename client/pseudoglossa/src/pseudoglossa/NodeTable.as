package pseudoglossa
{	
	import flash.utils.getQualifiedClassName;
	
	public class NodeTable
	{
		public var h:Object;
		public var algorithm:AlgorithmStatement;
		
		public function NodeTable(alg:AlgorithmStatement)
		{
			this.h = {};
			this.algorithm = alg;
		}
		
		public function getAlgorithms():Array
		{
			var acc:Array = [];
			for(var key:String in h) {
				if(h.hasOwnProperty(key) && h[key] is AlgorithmStatement) {
					acc.push(h[key]);
				}
			}
			return acc;
		}
		
		public function get(key:String):Object
		{
			if(h.hasOwnProperty(key)) {
				return h[key];
			} else {
				return null;
			}
		}
		
		public function has(key:String):Boolean
		{
			return h.hasOwnProperty(key);
		}
		
		public function set(key:String, o:Object):Object
		{
			h[key] = o;
			return o;
		}
		
		public function getCheckEntry(key:String, type:String):Object
		{
			var entry:Object = get(key);
			if(entry) {
				if(getQualifiedClassName(entry) != type) {
					throw new PNameError(PNameError.NAME_TYPE_NOT_COMPATIBLE, entry.line);
				}
			}
			return entry;
		}
		
		public function setCheckLValue(l:LValue):LValue
		{
			var entry:Object = get(l.name);
			if(entry) {
				if(entry is AlgorithmStatement) {
					throw new PTypeError(PTypeError.VARIABLE_IS_ALORITHM_NAME, l.line);
				} else {
					return entry as LValue;
				}
			}
			set(l.name, l);
			return l;
		}

		public function setCheckVar(variable:Variable):Variable
		{
			var entry:Object = get(variable.name);
			if(entry) {
				if(entry is ArrayStruct) {
					throw new PTypeError(PTypeError.VARIABLE_TYPE_MISMATCH, variable.line);
				} else if(entry is Variable) {
					return entry as Variable;
				} else {
					Checker.setLValue(entry, variable, algorithm.name);
				}
			} 
			set(variable.name, variable);
			return variable;
		}
		
		public function setCheckArray(arrayStruct:ArrayStruct):ArrayStruct
		{
			var entry:Object = get(arrayStruct.name);
			if(entry) {
				if(entry is ArrayStruct) {
					return entry as ArrayStruct;
				} else if(entry is Variable) {
					throw new PTypeError(PTypeError.VARIABLE_TYPE_MISMATCH, arrayStruct.line);
				} else {
					Checker.setLValue(entry, arrayStruct, algorithm.name);
				}
			}
			set(arrayStruct.name, arrayStruct);	
			return arrayStruct;	
		}
	}
}