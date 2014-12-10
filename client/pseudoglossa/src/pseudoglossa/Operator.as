package pseudoglossa
{
	import pseudoglossa.Helper;
	
	public class Operator
	{
		//TODO : fix utf operator chars
		public var type:String;
		public var value:String;
		public var isBinary:Boolean;
		public var precedence:int;
		public var key:String;
		public var modesCount:uint;
		public var modes:Object;
		
		public var _compute:Function;
		
		public static var binaryOperators:Array;
		public static var unaryOperators:Array;
		public static var SENTINEL:Operator;
		
		{
			Init();
		}

		public function Operator(key:String, value:String, type:String, isBinary:Boolean, precedence:int, modes:Object, compute:Function) 
		{
			this.key = key;
			this.value = value;
			this.type = type;
			this.isBinary = isBinary;
			this.precedence = precedence;
			this.modes = modes;
			isBinary ? binaryOperators[key] = this : unaryOperators[key] = this;		
			this.modesCount = 0;
			for(var i:String in modes) {			
				this.modesCount += 1;
			}
			_compute = compute;
		}
		
		public function getMode(type:String = 'VARIABLE'):Object
		{
			var mode:Object;
			if(type == 'VARIABLE' || type == 'LVALUE') {
				var r:Array = [];
				if(modesCount == 1) {
					for (var key:String in modes) {
						return modes[key];
					}
				} else {
					return modes['VARIABLE'];	
				}
			} else {
				var m:String;
				if (type == 'NUMBER') {
					m = 'NUMBER';
				} else {
					m = type;
				}
				return modes[m];	
			}
			return mode;
		}
	
		public function compute(...args):*
		{
			return _compute.apply(this, args);
		}

		public static function hasOperator(key:String, type:String = 'BINARY'):Boolean {
			var arr:Array = type == 'BINARY' ? Operator.binaryOperators : Operator.unaryOperators;
			return arr.hasOwnProperty(key);
		}
		public static function getOperator(key:String, type:String = 'BINARY'):Operator {
			var arr:Array = type == 'BINARY' ? Operator.binaryOperators : Operator.unaryOperators;
			return arr[key];
		}
		
		public function isComparison():Boolean {
			return type == 'COMPARISON';
		}

		public function getPrecedence():int {
			return precedence;
		}
		public function toString():String {
			return 'OPERATOR-' + type + '-' + value;
		}
		
		internal static function Init():void {
			binaryOperators = [];
			unaryOperators = [];
			
			
			//added number of modes, seek better solution
			SENTINEL = new Operator('@', 'SENTINEL', 'SENTINEL',true,-100,
				{
					DUMMY:{
						ACCEPTED_TYPES:['VARIABLE', 'LVALUE'],
						VAR_CAST:'VARIABLE',
						EXP_CAST:'VARIABLE'
					}
				}, null
			);
			new Operator('^', 'EXP', 'ARITHMETIC', true, 32,
				{
					NUMBER:	{
						ACCEPTED_TYPES:['NUMBER', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'NUMBER', 
						EXP_CAST:'NUMBER'
					}
				}, function(a:Number, b:Number):Number {
					return Math.pow(a, b);
				}
			);
			
			
			new Operator('*','MUL','ARITHMETIC',true,31,
				{
					NUMBER: {
						ACCEPTED_TYPES:['NUMBER', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'NUMBER', 
						EXP_CAST:'NUMBER'
					}
				}, function(a:Number, b:Number):Number {
					return a * b;
				}
			);
			 
			new Operator('/','DIV','ARITHMETIC',true,31,
				{
					NUMBER: {
						ACCEPTED_TYPES:['NUMBER', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'NUMBER', 
						EXP_CAST:'NUMBER'
					}
				}, function(a:Number, b:Number):Number {
					return a / b;
				}
			);
				
			new Operator('div','EDIV','ARITHMETIC',true,31,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'],
						VAR_CAST:'NUMBER',
						EXP_CAST:'NUMBER'
					}
				}, function(a:Number, b:Number):Number {
					return Math.floor(a / b);					
				}
			);
			new Operator('mod','EMOD','ARITHMETIC',true,31,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'],
						VAR_CAST:'NUMBER',
						EXP_CAST:'NUMBER'
					}
				}, function(a:Number, b:Number):Number {
					var r:Number = a % b;
					return r >= 0 ? r : r + Math.abs(b);
				}
			);
				
			new Operator('+','ADD','ARITHMETIC',true,30,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'NUMBER',
						EXP_CAST:'NUMBER'
					}
				}, function(a:Number, b:Number):Number {
					return a + b;
				}
			);
				
			new Operator('–','SUB','ARITHMETIC',true,30,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'NUMBER',
						EXP_CAST:'NUMBER'
					}
				}, function(a:Number, b:Number):Number {
					return a - b;
				}
			);
				
			
			new Operator('-','SUB','ARITHMETIC',true,30,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'NUMBER',
						EXP_CAST:'NUMBER'
					}
				}, function(a:Number, b:Number):Number {
					return a - b;
				}
			);
				
			
			new Operator('<=','LE','COMPARISON',true,20,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'],
						VAR_CAST:'NUMBER', 
						EXP_CAST:'BOOLEAN'
					},
					STRING:{
						ACCEPTED_TYPES :['STRING', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'STRING', 
						EXP_CAST:'BOOLEAN'
					},
					VARIABLE:{
						ACCEPTED_TYPES : ['VARIABLE', 'LVALUE'], 
						VAR_CAST:'VARIABLE', 
						EXP_CAST:'BOOLEAN'
					}
				}, function(a:*, b:*):Boolean {
					return a <= b;
				}
			);
			new Operator('≤','LE','COMPARISON',true,20,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'],
						VAR_CAST:'NUMBER', 
						EXP_CAST:'BOOLEAN'
					},
					STRING:{
						ACCEPTED_TYPES :['STRING', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'STRING', 
						EXP_CAST:'BOOLEAN'
					},
					VARIABLE:{
						ACCEPTED_TYPES : ['VARIABLE', 'LVALUE'], 
						VAR_CAST:'VARIABLE', 
						EXP_CAST:'BOOLEAN'
					}
				}, function(a:*, b:*):Boolean {
					return a <= b;
				}
			);
			new Operator('>=','GE','COMPARISON',true,20,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'],
						VAR_CAST:'NUMBER', 
						EXP_CAST:'BOOLEAN'
					},
					STRING:{
						ACCEPTED_TYPES :['STRING', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'STRING', 
						EXP_CAST:'BOOLEAN'
					},
					VARIABLE:{
						ACCEPTED_TYPES : ['VARIABLE', 'LVALUE'], 
						VAR_CAST:'VARIABLE', 
						EXP_CAST:'BOOLEAN'
					}
				}, function(a:*, b:*):Boolean {
					return a >= b;
				}
			);
			new Operator('≥','GE','COMPARISON',true,20,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'],
						VAR_CAST:'NUMBER', 
						EXP_CAST:'BOOLEAN'
					},
					STRING:{
						ACCEPTED_TYPES :['STRING', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'STRING', 
						EXP_CAST:'BOOLEAN'
					},
					VARIABLE:{
						ACCEPTED_TYPES : ['VARIABLE', 'LVALUE'], 
						VAR_CAST:'VARIABLE', 
						EXP_CAST:'BOOLEAN'
					}
				}, function(a:*, b:*):Boolean {
					return a >= b;
				}
			);	
			new Operator('>','GT','COMPARISON',true,20,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'],
						VAR_CAST:'NUMBER', 
						EXP_CAST:'BOOLEAN'
					},
					STRING:{
						ACCEPTED_TYPES :['STRING', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'STRING', 
						EXP_CAST:'BOOLEAN'
					},
					VARIABLE:{
						ACCEPTED_TYPES : ['VARIABLE', 'LVALUE'], 
						VAR_CAST:'VARIABLE', 
						EXP_CAST:'BOOLEAN'
					}
				}, function(a:*, b:*):Boolean {
					return a > b;
				}
			);
				
			new Operator('<','LT','COMPARISON',true,20,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'],
						VAR_CAST:'NUMBER', 
						EXP_CAST:'BOOLEAN'
					},
					STRING:{
						ACCEPTED_TYPES :['STRING', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'STRING', 
						EXP_CAST:'BOOLEAN'
					},
					VARIABLE:{
						ACCEPTED_TYPES : ['VARIABLE', 'LVALUE'], 
						VAR_CAST:'VARIABLE', 
						EXP_CAST:'BOOLEAN'
					}
				}, function(a:*, b:*):Boolean {
					return a < b;
				}
			);
			
			new Operator('=','EQ','COMPARISON',true,20,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'],
						VAR_CAST:'NUMBER', 
						EXP_CAST:'BOOLEAN'
					},
					STRING:{
						ACCEPTED_TYPES :['STRING', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'STRING', 
						EXP_CAST:'BOOLEAN'
					},
					VARIABLE:{
						ACCEPTED_TYPES : ['VARIABLE', 'LVALUE'], 
						VAR_CAST:'VARIABLE', 
						EXP_CAST:'BOOLEAN'
					},
					BOOLEAN: {
						ACCEPTED_TYPES :['VARIABLE', 'BOOLEAN', 'LVALUE'], 
						VAR_CAST:'BOOLEAN', 
						EXP_CAST:'BOOLEAN'
					}	
				}, function(a:*, b:*):Boolean {
					return a == b;
				}
			);
			new Operator('<>','NE','COMPARISON',true,20,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'],
						VAR_CAST:'NUMBER', 
						EXP_CAST:'BOOLEAN'
					},
					STRING:{
						ACCEPTED_TYPES :['STRING', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'STRING', 
						EXP_CAST:'BOOLEAN'
					},
					VARIABLE:{
						ACCEPTED_TYPES : ['VARIABLE'], 
						VAR_CAST:'VARIABLE', 
						EXP_CAST:'BOOLEAN'
					},
					BOOLEAN: {
						ACCEPTED_TYPES :['VARIABLE', 'BOOLEAN', 'LVALUE'], 
						VAR_CAST:'BOOLEAN', 
						EXP_CAST:'BOOLEAN'
					}	
				}, function(a:*, b:*):Boolean {
					return a != b;
				}
			);
			new Operator('≠','NE','COMPARISON',true,20,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'],
						VAR_CAST:'NUMBER', 
						EXP_CAST:'BOOLEAN'
					},
					STRING:{
						ACCEPTED_TYPES :['STRING', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'STRING', 
						EXP_CAST:'BOOLEAN'
					},
					VARIABLE:{
						ACCEPTED_TYPES : ['VARIABLE', 'LVALUE'], 
						VAR_CAST:'VARIABLE', 
						EXP_CAST:'BOOLEAN'
					},
					BOOLEAN: {
						ACCEPTED_TYPES :['VARIABLE', 'BOOLEAN', 'LVALUE'], 
						VAR_CAST:'BOOLEAN', 
						EXP_CAST:'BOOLEAN'
					}	
				}, function(a:*, b:*):Boolean {
					return a != b;
				}
			);
			new Operator('ή','OR','BOOLEAN',true,10,
				{
					BOOLEAN: {
						ACCEPTED_TYPES : ['BOOLEAN', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'BOOLEAN',
						EXP_CAST:'BOOLEAN'
					}
				}, function(a:Boolean, b:Boolean):Boolean {
					return a || b;
				}
			);
			new Operator('και','AND','BOOLEAN',true,10,
				{
					BOOLEAN: {
						ACCEPTED_TYPES : ['BOOLEAN', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'BOOLEAN',
						EXP_CAST:'BOOLEAN'
					}
				}, function(a:Boolean, b:Boolean):Boolean {
					return a && b;
				}
			);
			new Operator('όχι','NOT','BOOLEAN', false, 10,
				{
					BOOLEAN: {
						ACCEPTED_TYPES : ['BOOLEAN', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'BOOLEAN',
						EXP_CAST:'BOOLEAN'
					}
				}, function(a:Boolean):Boolean {
					return !a;
				}
			);
			new Operator('+','PLUS','ARITHMETIC',false,300,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'NUMBER',
						EXP_CAST:'NUMBER'
					}
				}, function(a:Number):Number {
					return a;
				}
			);
			
			new Operator('–','MINUS','ARITHMETIC',false,300,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'NUMBER',
						EXP_CAST:'NUMBER'
					}
				}, function(a:Number):Number {
					return -a;
				}
			);
			new Operator('-','MINUS','ARITHMETIC',false,300,
				{
					NUMBER: {
						ACCEPTED_TYPES : ['NUMBER', 'VARIABLE', 'LVALUE'], 
						VAR_CAST:'NUMBER',
						EXP_CAST:'NUMBER'
					}
				}, function(a:Number):Number {
					return -a;
				}
			);
			new Operator('..','CASE_OP','CASE',true,-1,
				{}, null
			);
		}
	}
}
