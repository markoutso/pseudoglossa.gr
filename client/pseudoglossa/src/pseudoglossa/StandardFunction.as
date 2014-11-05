package pseudoglossa
{
	public class StandardFunction
	{
		public var paramTypes:Array;
		public var name:String;
		public var type:String;
		public var _compute:Function;
		
//		public static var replacements:Object = {
//			'ημ': 'sin',
//			'συν': 'cos',
//			'εφ': 'tan',
//			'τοξ_εφ': 'atan',
//			'ε': 'exp',
//			'λογ': 'log',
//			'τ_ρ': 'sqr',
//			'α_τ': 'abs',
//			'α_μ': 'int',
//			'τυχαιοσ': 'random',
//			'μηκοσ': 'len',
//			'τυποσ': 'type'
//		}
		
		public static var standardFunctions:Object;
		
		{
			StandardFunction.Init();
		}
		
		public function StandardFunction(name:String, paramTypes:Array, type:String, compute:Function)
		{
			this.name = name;
			this.type = type;
			this.paramTypes = paramTypes;
			this._compute = compute;
			standardFunctions[Spec.normaliseGreek(name).toLowerCase()] = this;
		}
		
		public function compute(args:Array):*
		{
			return _compute.apply(this, args);
		}
		public static function isStandardFunction(key:String):Boolean
		{
			var nkey:String = Spec.normaliseGreek(key).toLowerCase();
			return standardFunctions.hasOwnProperty(nkey);// || replacements.hasOwnProperty(nkey);
		}
		public static function getStandardFunction(key:String):StandardFunction 
		{
			var nkey:String = Spec.normaliseGreek(key).toLowerCase();
			return standardFunctions[nkey];// || standardFunctions[replacements[nkey]];
		}
		
		public static function Init():void
		{
			standardFunctions = [];
			new StandardFunction('α_μ', ['NUMBER'], 'NUMBER', function(x:Number):Number {
				return x < 0 ? Math.ceil(x) : Math.floor(x);
			});
			new StandardFunction('εφ', ['NUMBER'], 'NUMBER', function(x:Number):Number {
				return Math.tan(Math.PI * x / 180);
			});
			
			new StandardFunction('συν', ['NUMBER'], 'NUMBER', function(x:Number):Number {
				return Math.cos(Math.PI * x / 180);
			});
			
			new StandardFunction('ημ', ['NUMBER'], 'NUMBER', function(x:Number):Number {
				return Math.sin(Math.PI * x / 180);
			});
			
			new StandardFunction('τοξ_εφ', ['NUMBER'], 'NUMBER', function(x:Number):Number {
				return Math.atan(Math.PI * x / 180);
			});
			
			new StandardFunction('λογ', ['NUMBER'], 'NUMBER', function(x:Number):Number {
				return Math.log(x);
			});

			new StandardFunction('τ_ρ', ['NUMBER'], 'NUMBER', function(x:Number):Number {
				return Math.sqrt(x);
			});
			
			new StandardFunction('α_τ', ['NUMBER'], 'NUMBER', function(x:Number):Number{
				return Math.abs(x);
			});
			
			new StandardFunction('ε', ['NUMBER'], 'NUMBER', function(x:Number):Number {
				return Math.exp(x);
			});
			
			new StandardFunction('τυχαιοσ', [], 'NUMBER', function():Number {
				return Math.random();
			});
			
			new StandardFunction('τυχαιοσ_ακεραιοσ', ['NUMBER', 'NUMBER'], 'NUMBER', function(left:Number, right:Number):Number {
				if (left > right) {
					var t: Number;
					t = right;
					right = left;
					left = t;
				}
				return Math.floor(left + Math.random() * (right - left + 1));
			});
			
			new StandardFunction('τυποσ', ['STRING'], 'STRING', function(name:String):String {
				var o:* = Environment.instance.frame.nodeTable.get(name) || Environment.instance.set.getAlgorithm(name) || getStandardFunction(name);
				if(!o) {
					throw new PRuntimeError(PRuntimeError.VARIABLE_NOT_INITIALISED);
				}
				if(o.type == 'ARRAY') {
					return 'ARRAY OF ' + o.elType;
				}
				return o.type;
			});
			
			new StandardFunction('μηκοσ', ['ARRAY', 'NUMBER'], 'NUMBER', function(v:*, dim:uint):Number {
				var k:String, dimension:uint, arr:Array = [0];
				for(k in v) {
					dimension = k.split(',').length;
					break;
				}
				if(dim > dimension) {
					throw new PRuntimeError(PRuntimeError.ARRAY_DIMENSION_ERROR);
				}
				for(k in v) {
					arr.push(Number(k.replace(/[\[\]]/g, '').split(',')[dim - 1]));
				}
				return Math.max.apply(null, arr);
			});
		}
	}
}
