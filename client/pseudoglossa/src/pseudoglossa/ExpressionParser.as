package pseudoglossa
{	
	public class ExpressionParser
	{
		protected var tokenList:TokenList;
		private var operators:Stack;
		private var operands:Stack;
		protected var currentOp:Operator;
		public var currentToken:Token;
		
		private static var SENTINEL:Operator = Operator.SENTINEL;		
					
		public function ExpressionParser(tokenList:TokenList)	
		{
			this.tokenList = tokenList;
			this.operators = new Stack();
			this.operands = new Stack();
		}
				
		protected function consume():void
		{
			currentToken = tokenList.next();
		}
		protected function unGet():void 
		{
			currentToken = tokenList.previous();
		}
		
		public function parseExpression():Expression 
		{
			operators.push(SENTINEL);
			consume();
			e();
			var exp:Expression = operands.top as Expression;
			unGet();
			return exp;
		}
		
		public function reset():void
		{
			operands.reset();
			operators.reset();
		}
		
		private function e():void 
		{
			p();
			while(isOp('BINARY')) {
				pushOperator(currentOp);
				consume();
				p();
			}
			
			while(operators.top != SENTINEL) {
				popOperator();
			}
			operators.pop();
		}

		public function parseParameterList(toSingleValue:Boolean = false):Array
		{
			var exps:Array = [], 
					parser:ExpressionParser = new ExpressionParser(tokenList),
					exp:Expression;
			exp = parser.parseExpression();
			if(exp is Variable && !toSingleValue) {
				exps.push(Variable(exp).toBaseLValue());
			} else {
				exps.push(exp);
			}
			parser.reset();
			var i:uint = 1;
			consume();
			while(currentToken.value == '@COMMA') {
				exp = parser.parseExpression();
				if(exp is Variable) {
					exps.push(Variable(exp).toBaseLValue());
				} else {
					exps.push(exp);
				}
				parser.reset();
				i++;
				consume();
			}
			unGet();
			return exps;
		}
		
		public function parseArrayElementExpression():ArrayElementExpression
		{
			var id:String, ars:ArrayStruct, exps:Array, arrExp:ArrayElementExpression, pos:uint;
			consume();
			pos = currentToken.pos;
			if(!currentToken.isName()) {
				throw new PSyntaxError(PSyntaxError.EXPECTED_NAME, currentToken);
			}
			id = currentToken.value;
			expect('@ARRAY_LEFT');
			exps = parseParameterList(true);
			expect('@ARRAY_RIGHT', PSyntaxError.EXPECTED_CHAR + ' ]');
			var arr:ArrayStruct = new ArrayStruct(id);
			arr.line = currentToken.line;
			arrExp = new ArrayElementExpression(arr, exps);
			arrExp.setLocation(pos, tokenList.getAreaLength(pos), currentToken.line);
			return arrExp;
			
		}
		
		public function parseAlgorithmExpression():AlgorithmExpression
		{
			var id:String, exps:Array, algorithm:AlgorithmStatement, algExp:AlgorithmExpression, pos:uint, tok:Token;
			consume();
			pos = currentToken.pos;
			if(!currentToken.isName()) {
				throw new PSyntaxError(PSyntaxError.EXPECTED_NAME, currentToken);
			}
			id = currentToken.value;
			expect('@PAR_LEFT', PSyntaxError.EXPECTED_PAR_LEFT);
			consume();
			if(currentToken.value != '@PAR_RIGHT') {
				unGet();
				exps = parseParameterList();
			} else {
				unGet();
			}
			algorithm = new AlgorithmStatement(id);
			expect('@PAR_RIGHT', PSyntaxError.EXPECTED_PAR_RIGHT);
			algExp = new AlgorithmExpression(algorithm, exps);
			algExp.setLocation(pos, tokenList.getAreaLength(pos),currentToken.line);
			return algExp;
		}
			
		private function p():void 
		{
			var s:LValue, tok:Token, c:Constant, exp:Expression;
			tok = currentToken;
			if(currentToken.isTerminal()) {
				if(currentToken.isName()) {
					if(checkAhead(1, '@ARRAY_LEFT')) {
						unGet();
						operands.push(parseArrayElementExpression());
					} else if(checkAhead(1, '@PAR_LEFT')) {
						unGet();
						operands.push(parseAlgorithmExpression());
					} else {
						s = new Variable(currentToken.value);
						s.setLocation(tok.pos, tokenList.getAreaLength(tok.pos), currentToken.line);
						operands.push(s);
					}
				} else {
					c = new Constant(currentToken.value, currentToken.type);
					c.setLocation(currentToken.pos, tokenList.getAreaLength(currentToken.pos), currentToken.line);
					operands.push(c);
				}
				consume();
			} else {
				if(currentToken.value == '@PAR_LEFT') {
					consume();
					operators.push(SENTINEL);
					e();
					expected('@PAR_RIGHT', PSyntaxError.EXPECTED_PAR_RIGHT);					
					exp = operands.top as Expression;
					exp.setLocation(tok.pos, tokenList.getAreaLength(tok.pos), currentToken.line);
					consume();
					//operators.pop();
				} else if(isOp('UNARY')) {
					pushOperator(currentOp);
					consume();
					p();
				} else {
					throw new PSyntaxError(PSyntaxError.EXPECTED_OPERAND, currentToken);
				}
			}
		}
		
		private function popOperator():void 
		{
			var op:Operator = operators.top as Operator;
			if(op.isBinary) {
				var t1:Expression = operands.pop();
				var t0:Expression = operands.pop();
				operands.push(mkNode(operators.pop(), t0 , t1));
			} else {
				operands.push(mkNode(operators.pop(), operands.pop()));
			}
		}
		protected function expect(what:String, errorMsg:String='', doConsume:Boolean=true):Boolean 
		{
			var c:String;
			if(doConsume) {
				consume();
			}
			if(currentToken.specKey) { 
				c = currentToken.specKey.value;
			} else { 
				c = currentToken.key;
			}
			if(c == what) {
				return true;
			}
			else {
				throw new PSyntaxError(errorMsg, currentToken);
				return false;
			}
		}
		protected function expected(what:String, errorMsg:String):Boolean
		{
			return expect(what, errorMsg, false);
		}
		
		public function checkAhead(n:uint, what:String):Boolean
		{
			var t:Token = tokenList.peek(n); 
			if (t) {
				if(t.specKey) {
					return t.specKey.value ==  what;
				} else {
					return t.key == what;
				}
			}
			return false;
		}
		
		private function pushOperator(op:Operator):void 
		{
			var sop:Operator = operators.top as Operator;
			while(mustPopOperator(sop, op)) {
				popOperator();
				sop = operators.top as Operator;
			}
			operators.push(op);
		}
		private function mustPopOperator(op1:Operator, op2:Operator):Boolean 
		{
			if(op1.value == 'SENTINEL' || !op2.isBinary) {
				return false;
			} else {
				return op1.precedence >= op2.precedence;
			}
			
		}
		protected function isOp(type:String):Boolean 
		{
			if(currentToken.isOperator()) {
				if(Operator.hasOperator(currentToken.specKey.key, type)) {
					currentOp = Operator.getOperator(currentToken.specKey.key, type);
					return true;
				}				
			}
			return false;
		}	
		private function mkNode(op:Operator, exp1:Expression, exp2:Expression = null):Expression 
		{
			var exp:Expression;
			if(exp2) {
				exp = new BinaryExpression(op, exp1, exp2);
				var length:uint = (exp2.from + exp2.length) - exp1.from;		
				if(length < 0) length = tokenList.getAreaLength(exp1.from) - 1;
				exp.setLocation(exp1.from, length, currentToken.line);
				return exp;
			} else {
				var oppos:uint = exp1.from - op.key.length;
				exp = new UnaryExpression(op, exp1);
				exp.setLocation(oppos, (exp1.from + exp1.length) - oppos, currentToken.line);
				return exp; 
			}
		}
	}
}	
					
