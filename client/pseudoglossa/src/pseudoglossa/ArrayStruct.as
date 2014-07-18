package pseudoglossa
{	
	public class ArrayStruct extends LValue
	{
		public var dimension:uint;
		public var elType:String;

		public function ArrayStruct(name:String)
		{
			super(name);
			this.dimension = 0;
			this.type = 'ARRAY';
			this.line = line;
			this.elType = 'VARIABLE';
		}
		
		override public function toSingleValued(t:String):*
		{
			throw new PTypeError(PTypeError.EXPRESSION_NOT_VARIABLE, line);
		}
		
		override public function toArray(arr:ArrayStruct = null):ArrayStruct
		{
			if(arr && arr.dimension != dimension) {
				throw new PTypeError(PTypeError.DIMESION_MISMATCH, arr.line);
			}
			return this;
		}
		
		public function get variables():Object
		{
			var vars:Object = Environment.instance.frame.symbolTable.get(name);
			if(vars == null) {
				vars = {};
				Environment.instance.frame.symbolTable.set(name, vars);
			}
			return vars;
		}
		
		override public function set value(v:*):void
		{
			Environment.instance.frame.symbolTable.set(name, v);
		}
		
		override public function set valueFromInput(v:*):void
		{
			var k:String;
			if (type == 'BOOLEAN') {
				for(k in v) {
					v[k] = Boolean(v[k]);
				}
			} else if (type != 'STRING') {
				for(k in v) {
					v[k] = Number(v[k]);
				}
			}
			value = v;
		}
		
		public function setElFromInput(indexes:Array, v:*):void
		{
			var value:*,
				k:String = key(indexes);
			if (type == 'BOOLEAN') {
				value = Boolean(v);
			} else if (type != 'STRING') {
				value = Number(v);
			} else {
				value = v;
			}
			variables[k] = value;
			//FIXME: remove watch window logic
			var entry:Object = {}; 
			entry[k] = value;
			Environment.instance.frame.symbolTable.updateArrayInCollection(name, entry);
			
		}
		
		override public function get printVal():String
		{
			var acc:Array = [],
				ret:Array = [],
				arr:Array,
				i:uint;
			for(var k:String in variables) {
				acc.push({index: keyToInt(k), key: k, value: variables[k]});
			}
			acc = acc.sort(function(a:Object, b:Object):int {
				return a.index - b.index;
			});
			for each(var obj:Object in acc) {
				ret.push(obj.key + ' : ' + obj.value);
			}
			return ret.join('\r');
		}
		
		public function keyToInt(key:String):uint
		{
			var arr:Array, i:uint, ret:uint = 0;
			key = key.replace('[', '').replace(']', '');
			arr = key.split(',');
			for(i = 0; i < arr.length; i += 1) {
				ret += arr[i] * Math.pow(10, dimension - i);
			}
			return ret;
		}
		
		override public function get value():*
		{
			return variables; 
		}

		public function key(indexes:Array):String
		{
			var acc:Array = [];
			for(var i:uint = 0; i < indexes.length; i += 1) {
				acc.push(indexes[i].toString());
			}
			return '[' + acc.join(',') + ']';
		}
		
		public function setElValue(indexes:Array, value:*):void
		{
			var k:String = key(indexes),
				entry:Object = {};
			variables[k] = value;
			//FIXME: remove watch window logic
			entry[k] = value;
			Environment.instance.frame.symbolTable.updateArrayInCollection(name, entry);
		}
		
		public function getParentFrameEl(indexes:Array):*
		{
			return Environment.instance.parentFrame.symbolTable.get(name)[key(indexes)];	
		}
		
		public function setParentFrameEl(indexes:Array, value:*):void
		{
			Environment.instance.parentFrame.symbolTable.get(name)[key(indexes)] = value;
		}
		
		public function getEl(indexes:Array):*
		{
			return variables[key(indexes)];
		}
		
		public static function restorePos(dim:Array, index:uint):Array
		{
			var prod:uint, pos:Array = [];
			for(var i:uint = 0; i < dim.length; i += 1) {
				prod = 1;
				for(var j:uint = i + 1; j < dim.length; j += 1) {
					prod *= dim[j]
				}
				pos.push(Math.floor((index - 1) / prod) + 1 );
				index -= (pos[i] - 1) * prod;
			}
			return pos;
		}
		
		public static function flattenDim(dim:Array, pos:Array):uint
		{
			var prod:uint, index:uint = 0;
			for(var i:uint = 0; i < dim.length; i +=1) {
				prod = 1;
				for(var j:uint = i + 1; j < dim.length; j += 1) {
					prod *= dim[j];
				}
				index += (pos[i] - 1) * prod;
			}
			return index + 1;
		}
	}
}