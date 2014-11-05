package pseudoglossa
{
	public class Parser extends ExpressionParser
	{
		public var openStatements:Stack;
		public var algorithmName:String;
		private var endSelect:Boolean;
		private var currentAlgorithm:AlgorithmStatement;
		public var parsed:Boolean;

		public function Parser(tokenList:TokenList)	
		{
			super(tokenList);
			this.openStatements = new Stack();
			this.ignoreSpaces();
		}		
		public function ignoreSpaces():void 
		{
			consume();
			while(currentToken.value == '@EOL') {
				consume();
			}
			unGet();
		}
		
		public function parseAlgorithmName():String 
		{
			consume();
			if(currentToken.type != 'NAME') {
				throw new PSyntaxError(PSyntaxError.EXPECTED_NAME, currentToken);
			}
			return currentToken.value;
		}
		
		public function parseName():String 
		{
			consume();
			if(currentToken.type != 'NAME') {
				throw new PSyntaxError(PSyntaxError.EXPECTED_NAME, currentToken);
			}
			return currentToken.value;
		}
		
		public function expectNewLine():void 
		{
			expect('@EOL', PSyntaxError.EXPECTED_EOL);
			consume();
			while(currentToken.type == 'EOL') {
				consume();
			}
			unGet();
		}
		
		public function pushOpenStatements(statement:Statement):void 
		{
			openStatements.push(statement);
		}
		
		public function popOpenStatements():Statement 
		{
			return openStatements.pop();
		}
		
		public function parseCall():CallStatement
		{
			var exp:AlgorithmExpression;
			expect('@CALL');
			exp = parseAlgorithmExpression();
			var callstat:CallStatement = new CallStatement(exp);
			return callstat;
		}
		
		public function parseAlgorithmStatement():AlgorithmStatement 
		{
			var algorithmStatement:AlgorithmStatement;
			expect('@ALGORITHM', PSyntaxError.EXPECTED_ALGORITHM);
			algorithmName = parseAlgorithmName();
			algorithmStatement = new AlgorithmStatement(algorithmName);
			algorithmStatement.line = currentToken.line;
			currentAlgorithm = algorithmStatement;
			expectNewLine();
			pushOpenStatements(algorithmStatement);
			consume();
			
			if(currentToken.value == '@DATA') 	{
				algorithmStatement.statements.push(parseData());
				expectNewLine();
				consume();
			} else {
				algorithmStatement.statements.push(new DataStatement());
			}
			while(currentToken.value != '@RESULTS' && currentToken.value != '@END') {
				unGet();
				algorithmStatement.statements.push(parseStatement());
				consume();
			}
			if(currentToken.value == '@RESULTS') {
				algorithmStatement.statements.push(parseResults());
				expectNewLine();
				expect('@END', PSyntaxError.EXPECTED_END);
			} else {
				algorithmStatement.statements.push(new ResultsStatement())
			}
			algorithmStatement.endLine = currentToken.line;
			var name:String = parseAlgorithmName();
			if(algorithmName != name) {
				throw new PSyntaxError(PSyntaxError.EXPECTED_ALGORITHM_IDENTIFIER, currentToken);
			}
			popOpenStatements();
			return algorithmStatement;
		}
		
		public function parse():Array
		{
			var algorithms:Array = [], algorithm:AlgorithmStatement;
			algorithm = parseAlgorithmStatement();
			algorithms.push(algorithm);
			ignoreSpaces();
			consume();
			while(currentToken.type != 'EOF') {
				unGet();
				algorithm = parseAlgorithmStatement();
				algorithms.push(algorithm);
				ignoreSpaces();
				consume();
			}		
			return algorithms;
		}
		
		public function parseLValueList(toSingleValued:Boolean = false):Array
		{
			var lvalues:Array = [];
			lvalues.push(parseLValue(toSingleValued));
			consume();
			while(currentToken.value == '@COMMA') {
				lvalues.push(parseLValue(toSingleValued));
				consume();
			}
			unGet();
			return lvalues;
		}
		
		public function parseData():DataStatement 
		{
			var dataStatement:DataStatement = new DataStatement();
			dataStatement.line = currentToken.line;
			expect('@DS', PSyntaxError.EXPECTED_DS);
			dataStatement.params = parseLValueList();
			expect('@DS', PSyntaxError.EXPECTED_DS);
			return dataStatement;
		}
		
		public function parseResults():ResultsStatement
		{
			var resultsStatement:ResultsStatement = new ResultsStatement();
			resultsStatement.line = currentToken.line;
			expect('@DS', PSyntaxError.EXPECTED_DS);
			resultsStatement.params = parseLValueList();
			expect('@DS', PSyntaxError.EXPECTED_DS);
			return resultsStatement;
		}
				
		public function parseStatement(doExpectNewLine:Boolean = true):Statement 
		{	
			var statement:Statement, tok:Token = tokenList.peek(1);
			var top:ContainerStatement = openStatements.top as ContainerStatement;
			if(!tok) {
				var msg:String;
				msg = PSyntaxError.UNEXPECTED_END + '\n';
				msg += PSyntaxError.LAST_OPEN_STATEMENT + ': ' + top.desc + ' στην γραμμή ' + currentToken.line;
				throw new PSyntaxError(msg, currentToken);
			}
			if(tok.value == '@READ') {
				statement = parseRead();
			} else if (tok.value == '@WRITE') {
				statement = parseWrite();
			} else if(tok.value == '@CLS') {
				statement = parseCls();
			} else if(tok.type == 'NAME') {
				statement = parseAssignment();
			} else if(tok.value == '@IF') {
				statement = parseIf();
			} else if(tok.value == '@SWAP') {
				statement = parseSwap();
			} else if(tok.value == '@WHILE') {
				statement = parseWhile();
			} else if(tok.value == '@DO' || tok.value == '@REPEAT') {
				statement = parseDo(tok.value);
			} else if(tok.value == '@FOR') {
				statement = parseFor();
			} else if(tok.value == '@SELECT') {
				statement = parseSelect();
			} else if(tok.value == '@CALL') {
				statement = parseCall();
			} else {
				consume();			
				var v:String = currentToken.specKey ? currentToken.specKey.key : currentToken.value;
				msg =  PSyntaxError.UNEXPECTED_STATEMENT + ': ' + v + '\n';
				msg += PSyntaxError.LAST_OPEN_STATEMENT + ': ' + top.desc + ' στην γραμμή ' + top.line;
				throw new PSyntaxError(msg, currentToken);			
			}
			statement.line = tok.line;
			statement.endLine = currentToken.line;

			if(doExpectNewLine) {
				expectNewLine();
			}
			return statement;
		}
		
		public function parseCls():ClsStatement
		{
			expect('@CLS', PSyntaxError.EXPECTED_CLS);
			return new ClsStatement();			
		}
		
		public function parseRead():ReadStatement 
		{
			expect('@READ', PSyntaxError.EXPECTED_READ);
			var readStatement:ReadStatement = new ReadStatement();
			readStatement.params = parseLValueList(true);
			return readStatement;
		}
		
		public function parseWrite():WriteStatement 
		{
			expect('@WRITE', PSyntaxError.EXPECTED_WRITE);
			var writeStatement:WriteStatement = new WriteStatement();
			writeStatement.params = parseParameterList(true);
			return writeStatement;
		}
		
		public function parseAssignment():AssignmentStatement 
		{
			var assignmentStatement:AssignmentStatement = new AssignmentStatement(parseLValue());
			expect('@ASSIGN', PSyntaxError.EXPECTED_ASSIGNMENT);
			var expression:Expression = parseExpression();
			assignmentStatement.expression = expression;
			return assignmentStatement;
		}
		
		public function parseLValue(toSingleValued:Boolean = false):LValue
		{
			var id:String = parseName();
			if(checkAhead(1, '@ARRAY_LEFT')) {
				unGet();
				return parseArrayElementExpression();
			} else {
				var l:LValue;
				if(toSingleValued) {
					l = new Variable(id);
				} else {
					l = new LValue(id);
				}
				 
				l.line = currentToken.line;
				return l;
			}
		}
		
		public function parseIf():IfStatement 
		{
			expect('@IF')
			var condition:Expression = parseExpression();
			var ifStatement:IfStatement = new IfStatement(condition);
			pushOpenStatements(ifStatement);
			expect('@THEN', PSyntaxError.EXPECTED_THEN);
			consume()
			if(currentToken.value != '@EOL'){ //απλή επιλογή χωρίς αλλιώς σε μια γραμμή
				unGet();
				ifStatement.statements.push(parseStatement(false));
				ifStatement.isSimple = true;
			} else {
				unGet();
				expectNewLine();
				consume();
				while(currentToken.value != '@END_IF' && currentToken.value != '@ELSE'
					&& currentToken.value != '@ELSE_IF') {
					unGet();
					ifStatement.statements.push(parseStatement());
					consume();								
				}
				while(currentToken.value == '@ELSE_IF') {
					var elseIfStatement:ElseIfStatement = parseElseIf(ifStatement);
					ifStatement.elseIfStatements.push(elseIfStatement);		
				}
				if(currentToken.value == '@ELSE') {
					ifStatement.setHasElse(currentToken.line);
					expectNewLine();
					consume();
					while(currentToken.value != '@END_IF') {
						unGet();						
						ifStatement.elseStatements.push(parseStatement());
						consume();
					}
				}
			}
			popOpenStatements();
			return ifStatement;
		}
		
		public function parseElseIf(ifStatement:IfStatement):ElseIfStatement 
		{
			var condition:Expression = parseExpression();
			var elseIfStatement:ElseIfStatement = new ElseIfStatement(condition, ifStatement);
			elseIfStatement.line = currentToken.line;
			expect('@THEN', PSyntaxError.EXPECTED_THEN);
			expectNewLine();
			consume();
			while(currentToken.value != '@END_IF' && currentToken.value != '@ELSE'
					&& currentToken.value != '@ELSE_IF') {
				unGet();
				elseIfStatement.statements.push(parseStatement());
				consume();								
			}
			return elseIfStatement;
		}
		
		public function parseSwap():SwapStatement 
		{
			expect('@SWAP');
			var swapStatement:SwapStatement = new SwapStatement();
			var l1:LValue = parseLValue(true);
			expect('@COMMA', PSyntaxError.EXPECTED_COMMA);
			var l2:LValue = parseLValue(true);
			swapStatement.lvalue1 = l1;
			swapStatement.lvalue2 = l2
			return swapStatement;
		}	
		
		public function parseWhile():WhileStatement 
		{
			expect('@WHILE');
			var condition:Expression = parseExpression();
			var whileStatement:WhileStatement = new WhileStatement(condition);
			pushOpenStatements(whileStatement);
			expect('@REPEAT', PSyntaxError.EXPECTED_WHILE_BEGIN);
			expectNewLine();
			consume();
			while(currentToken.value != '@END_LOOP') {
				unGet();
				whileStatement.statements.push(parseStatement());
				consume();
			}
			popOpenStatements();
			return whileStatement;
		}
		
		public function parseDo(val:String):RepeatStatement 
		{
			if(val == '@DO') {
				expect('@DO');	
			} else {
				expect('@REPEAT');
			}
			
			var repeatStatement:RepeatStatement = new RepeatStatement();
			expectNewLine();			
			pushOpenStatements(repeatStatement);
			consume();
			while(currentToken.value != '@UNTIL') {
				unGet();
				repeatStatement.statements.push(parseStatement());
				consume();
			}
			var condition:Expression = parseExpression();
			repeatStatement.condition = condition;
			popOpenStatements();
			return repeatStatement;
		}
		
		public function parseFor():ForStatement 
		{
			var lvalue:LValue;
			expect('@FOR');
			lvalue = parseLValue(true);
			var forStatement:ForStatement = new ForStatement(lvalue);
			pushOpenStatements(forStatement);
			expect('@FOR_START', PSyntaxError.EXPECTED_FOR_START);
			forStatement.start = parseExpression();
			expect('@FOR_END', PSyntaxError.EXPECTED_FOR_END);
			forStatement.end = parseExpression();
			consume();
			if(currentToken.value == '@STEP') {
				forStatement.step = parseExpression();
			} else {
				forStatement.step = new Constant('1', 'NUMBER');
				unGet();
			}
			expectNewLine();
			consume();
			while(currentToken.value != '@END_LOOP') {
				unGet();
				forStatement.statements.push(parseStatement());
				consume();
			}
			popOpenStatements();
			return forStatement;
		}

		public function parseSelect():SelectStatement 
		{		
			expect('@SELECT');
			endSelect = false;
			var selectStatement:SelectStatement = new SelectStatement();
			pushOpenStatements(selectStatement);
			var selector:Expression = parseExpression();
			selectStatement.selector = selector;
			expectNewLine();
			consume();
			while(currentToken.value != '@END_SELECT') {
				unGet();
				if(endSelect) {
					consume();
					throw new PSyntaxError(PSyntaxError.EXPECTED_END_SELECT, currentToken);
				}
				var caseStatement:CaseStatement = parseCase(selectStatement);
				selectStatement.statements.push(caseStatement);
				consume();
			}
			popOpenStatements();
			return selectStatement;
		}
		
		public function parseCase(selectStatement:SelectStatement):CaseStatement
		{
			expect('@CASE', PSyntaxError.EXPECTED_CASE);
			var caseStatement:CaseStatement = new CaseStatement(selectStatement);
			caseStatement.line = currentToken.line;
			pushOpenStatements(caseStatement);
			parseCaseExpressions(caseStatement);
			consume();
			while(currentToken.value != '@CASE' && currentToken.value != '@END_SELECT') {
				unGet();
				caseStatement.statements.push(parseStatement());
				consume();
			}
			unGet();
			popOpenStatements();
			return caseStatement;
		}
		
		public function parseCaseExpressions(caseStatement:CaseStatement):void 
		{
			var exp:CaseExpression = parseCaseExpression();
			exp.setCaseStatement(caseStatement);
			consume();
			while(currentToken.value == '@COMMA' && !exp.isElse) {
				exp = parseCaseExpression();
				exp.setCaseStatement(caseStatement);
				consume();
			}
			unGet();
			expectNewLine();
			endSelect = exp.isElse;
		}
		
		public function parseCaseExpression():CaseExpression 
		{
			consume();
			parsed = false;
			var ce:CaseExpression;
			var exp1:Expression;
			var exp2:Expression;
			if(isOp('BINARY')) {
				if(currentOp.isComparison()) {
					var opToken:Token = currentToken;
					var op:Operator = currentOp;
					exp1 = parseExpression();
					if(exp1.type == 'BOOLEAN' && currentOp.value != 'EQ' && currentOp.value != 'NE') {
						throw new PSyntaxError(PSyntaxError.INVALID_BOOLEAN_EXPRESSION, opToken);
					} else {
						ce = new CaseExpression(exp1, op);
					}
				} else {
					if(isOp('UNARY')) {
						unGet();
						exp1 = parseExpression();
						ce = new CaseExpression(exp1);
					}
				}
			} else {
				if(currentToken.value == '@ELSE') {
					return new CaseExpression(new Constant('@ELSE', 'CASE_ELSE'));
				}
				unGet();
				exp1 = parseExpression();
				consume();
				if(currentToken.value == '@CASE_OP') {
					exp2 = parseExpression();
					ce = new CaseExpression(exp1, Operator.getOperator('..'), exp2);
				} else {
					unGet();
					ce = new CaseExpression(exp1);
				}
			}
			return ce;			
		}
		
	}
}
			