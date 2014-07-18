package pseudoglossa
{
	import flash.utils.getQualifiedClassName;

	public class Checker
	{
		public var algorithm:AlgorithmStatement;
		public var bond:Array;
		public var warnings:Array;
		public var userAlgorithms:Array;
		public var frame:Frame;
		
		public static var TYPE_COMP:Object = {
			'VARIABLE': ['VARIABLE', 'NUMBER', 'STRING', 'BOOLEAN', 'LVALUE'],
			'NUMBER': ['VARIABLE', 'NUMBER', 'LVALUE'],
			'STRING': ['VARIABLE', 'STRING', 'LVALUE'],
			'BOOLEAN': ['BOOLEAN', 'VARIABLE', 'LVALUE'],
			'ARRAY': ['ARRAY', 'LVALUE'],
			'LVALUE': ['LVALUE', 'VARIABLE', 'NUMBER', 'STRING', 'BOOLEAN']
		};

		public static function areComp(type1:String, type2:String):Boolean
		{
			return Checker.TYPE_COMP[type1].indexOf(type2) > -1;
		}
		
		public static function hasType(exp:Expression):Boolean
		{
			return exp.type != 'VARIABLE' && exp.type != 'LVALUE';
		}
		
		public static function isNumberValue(value:*):Boolean
		{
			return isFinite(value) && !isNaN(value);
		}
		
		public static function guessType(value:String):String
		{			
			if(!Checker.isNumberValue(value)) {
				return 'STRING';
			}
			return 'VARIABLE';
		}
		
		public static function setLValueAgainstString(obj:Object, against:String, algName:String):*
		{
			var ret:*;
			if(obj is LValue && obj.type == 'LVALUE' && against != 'LVALUE') {
				if(against == 'ARRAY') {
					ret = LValue(obj).toArray(null);
				} else {
					ret = LValue(obj).toSingleValued(against);
				}
				for each(var f:Frame in Frame.frames[algName]) {
					f.ntBuilder.updateLValue(ret);
				}
				return ret;
			}
			return obj;
		}

		public static function setLValue(obj:Object, against:Object, algName:String):*
		{
			var ret:*;
			if(obj is LValue && obj.type == 'LVALUE' && against.type != 'LVALUE') {
				if(against.type == 'ARRAY') {
					ret = LValue(obj).toArray(against as ArrayStruct);
				} else {
					ret = LValue(obj).toSingleValued(against.type);
				}
				for each(var f:Frame in Frame.frames[algName]) {
					f.ntBuilder.updateLValue(ret);
					f.checker.setType(ret, ret.type);
				}
				return ret;
			}
			return obj;
		}
		
		public function Checker(algorithm:AlgorithmStatement, frame:Frame)
		{
			this.algorithm = algorithm;
			this.bond = [];
			this.warnings = [];
			this.frame = frame;
		}
		
		public function check():void {
			var st:Statement;
			for each (st in algorithm.statements) {
				checkStatement(st);
			}
		}
		
		public function checkStatements(statements:Array):void
		{
			var st:Statement;
			for each(st in statements) {
				checkStatement(st);
			}
		}
		
		public function checkStatement(st:Statement):void
		{
			if (st is AssignmentStatement) {
				checkAssignment(st as AssignmentStatement);	
			} else if (st is IfStatement) {
				checkIf(st as IfStatement);
			} else if ( st is SelectStatement) {
				checkSelect(st as SelectStatement);
			} else if (st is WhileStatement) {
				checkWhile(st as WhileStatement);
			} else if (st is RepeatStatement) {
				checkRepeat(st as RepeatStatement);
			} else if (st is ForStatement) {
				checkFor(st as ForStatement);
			} else if (st is SwapStatement) {
				checkSwap(st as SwapStatement);
			} else if (st is WriteStatement) {
				checkWrite(st as WriteStatement);
			} else if (st is CallStatement) {
				checkCall(st as CallStatement);
			}
		}
		
		public function checkCall(call:CallStatement):void
		{
			if(!call.exp.algorithm.data) {
				throw new PTypeError(PTypeError.UNKNOWN_ALGORITHM, call.line);
			}
			var names:Array = [],
				all:Array = call.exp.algorithm.data.params.concat(call.exp.algorithm.results.params);
			for each(var exp:Object in all) {
				if(names.indexOf(exp.name) == -1) {
					names.push(exp.name);
				}
			}
			if(call.exp.params.length != names.length) {
				throw new PTypeError(PTypeError.PARAM_COUNT_MISMATCH, call.line);
			}
			checkCallParams(call.exp, call.exp.params, call.exp.algorithm.data.params);
			checkCallParams(call.exp, call.exp.params, call.exp.algorithm.results.params, call.exp.algorithm.outParamIndexes());
		}
		
		public function checkWrite(write:WriteStatement):void
		{
			var exp:Expression;
			for each (exp in write.params) {
				checkExpression(exp);
			}
		}
		
		public function checkSwap(swap:SwapStatement):void
		{
			if(hasType(swap.lvalue1)) {
				if(!hasType(swap.lvalue2)) {
					setType(swap.lvalue2, swap.lvalue1.type);
				}
			} else if (hasType(swap.lvalue2)) {
				setType(swap.lvalue1, swap.lvalue2.type);
			} else {
				bind(swap.lvalue1, swap.lvalue2);
			}
			if(swap.lvalue1.type != swap.lvalue2.type) {
				throw new PTypeError(PTypeError.SWAP_VARIABLE_MISMATCH, swap.lvalue1.line);
			}
		}
		
		public function checkFor(forstat:ForStatement):void
		{
			var exp:Expression;
			checkNumber(forstat.lvalue);
			for each (exp in [forstat.start, forstat.end, forstat.step]) {
				checkExpression(exp);
				checkNumber(exp);
			}
			checkStatements(forstat.statements);
			
		}
		
		public function checkNumber(exp:Expression):void
		{
			if (exp.type != 'VARIABLE' && exp.type != 'NUMBER') {
				throw new PTypeError(PTypeError.NUMBER_ERROR, exp.line);
			}
			if (exp is LValue) {
				setType(exp, 'NUMBER');
			}
		}
		
		public function checkRepeat(repeat:RepeatStatement):void
		{
			checkCondition(repeat.condition);
			checkStatements(repeat.statements);
		}
		
		public function checkWhile(whilest:WhileStatement):void
		{
			checkCondition(whilest.condition);
			checkStatements(whilest.statements);
		}
		
		public function setType(l:Object, type:String):void
		{
			if(type == 'VOID') {
				throw new PTypeError(PTypeError.NULL_ALGORITHM_EXPRESSION, l.line);
			}
			if(l.type == 'LVALUE') {
				if(type == 'ARRAY') {
					l = LValue(l).toArray();
				} else {
					l = LValue(l).toSingleValued(type);
				}
				bond[l.name] = l;
			}
			l.type = type;
			setBondedType(l);	
		}
		
		public function isCondition(expression:Expression):Boolean
		{
			return expression.type == 'BOOLEAN' || expression.type == 'VARIABLE';
		}
		
		public function checkCondition(condition:Expression):void
		{
			checkExpression(condition);
			if (!isCondition(condition)) {
				throw new PTypeError(PTypeError.CONDITION_ERROR, condition.line);
			}
			if (condition is LValue) {
				setType(condition, 'BOOLEAN');
			}
		}
		
		public function checkSelect(select:SelectStatement):void
		{
			var casest:CaseStatement;
			checkExpression(select.selector);
			for each (casest in select.statements) {
				checkCase(casest);
			}
		}
		
		public function checkCase(casest:CaseStatement):void
		{
			var caseExp:CaseExpression;
			for each (caseExp in casest.expressions) {
				checkCaseExp(caseExp);
			}
			checkStatements(casest.statements);
		}
		
		public function checkCaseExp(caseExp:CaseExpression):void
		{
			if(caseExp.isElse) {
				return;
			}
			var casestat:CaseStatement = caseExp.caseStatement;
			var selectstat:SelectStatement = casestat.select;
			var exp1:Expression = caseExp.exp1, exp2:Expression = caseExp.exp2;
			checkExpression(exp1);
			if (exp2) {
				checkExpression(exp2);
			}
			if(!hasType(selectstat.selector)) {
				if(hasType(caseExp.exp1)) {
					selectstat.selector.type = caseExp.exp1.type;
					if(selectstat.selector is LValue) {
						setType(selectstat.selector, exp1.type);
					}
					if(exp2) {
						if(!hasType(exp2)) {
							exp2.type = exp1.type;
							if(exp2 is LValue) {
								setType(exp2, exp1.type)
							}
						}
					}
				} else if(exp2 && !hasType(exp2)) {
					selectstat.selector.type = exp2.type;
					if(selectstat.selector is LValue) {
						setType(selectstat.selector, exp2.type);
					}
					if(!hasType(exp1)) {
						exp1.type = exp2.type;
						if(exp1 is LValue) {
							setType(exp1, exp2.type)
						}
					}
				} else {
					if(selectstat.selector is LValue && exp1 is LValue) {
						bind(selectstat.selector, exp1);
						if(exp2) {
							bind(selectstat.selector, exp2);
							bind(exp1, exp2);
						}
					}
				}	
			} else {
				if(!hasType(exp1) && exp1 is LValue) {
					setType(exp1, selectstat.selector.type);
				}
				if(exp2 && hasType(exp2) && exp2 is LValue) {
					setType(exp2, selectstat.selector.type);
				}
			}
			if(exp1.type != selectstat.selector.type) {
				throw new PTypeError(PTypeError.SELECT_SELECTOR_ERROR, exp1.line);
			}
			if(exp2) {
				if(exp2.type != selectstat.selector.type) {
					throw new PTypeError(PTypeError.SELECT_SELECTOR_ERROR, exp2.line);
				}
				if(exp1.type != exp2.type) {
					throw new PTypeError(PTypeError.SELECT_CASE_EXPRESSION_ERROR, exp1.line);
				}
			}
		}
		
		public function checkIf(ifstat:IfStatement):void
		{
			var elseif:ElseIfStatement;
			checkCondition(ifstat.condition);
			checkStatements(ifstat.statements);
			for each (elseif in ifstat.elseIfStatements)  {
				checkCondition(elseif.condition);
				checkStatements(elseif.statements);
			}
			checkStatements(ifstat.elseStatements);
		}
		
		public function checkAssignment(assignment:AssignmentStatement):void
		{
			checkExpression(assignment.lvalue);
			checkExpression(assignment.expression);
			
			setLValue(assignment.lvalue, assignment.expression, algorithm.name);
			setLValue(assignment.expression, assignment.lvalue, algorithm.name);
			
			var lvalue:Expression = assignment.lvalue, 
				expression:Expression = assignment.expression, 
				type:String;
			
			if(!hasType(lvalue)) {
				if(hasType(expression)) {
					setType(lvalue, expression.type); 
				} else if(expression is LValue) {
					bind(lvalue, expression);
				}
			} else {
				if(!hasType(expression)) {
					if(expression is LValue) {
						setType(expression, lvalue.type)
					} else {
						expression.type = lvalue.type;
					}
				}
				if(!Checker.areComp(expression.type, lvalue.type)) {
					throw new PTypeError(PTypeError.VARIABLE_TYPE_MISMATCH, expression.line);
				}
			}
		}
		
		public function checkExpression(exp:Expression):void
		{
			if (exp is UnaryExpression) {
				checkUnary(exp as UnaryExpression);
			} else if (exp is BinaryExpression) {
				checkBinary(exp as BinaryExpression);
			} else if (exp is StandardFunctionExpression) {
				checkStandardFunction(exp as StandardFunctionExpression);
			} else if (exp is ArrayElementExpression) {
				checkArrayExpression(exp as ArrayElementExpression);
			} else if (exp is AlgorithmExpression) {
				checkAlgorithmExpression(exp as AlgorithmExpression);
			}
		}
		
		public function checkCallParams(aexp:AlgorithmExpression, callParams:Array, algParams:Array, indexes:Array = null):void
		{
			/*
				callParams: parameters used in call(might be expressions)
				algParams: algorithm data or result parameters
			*/
			/* 
			FIXME: callee::check has not yet been called so
			variables have no type yet
			temp fix: run checker twice in AlgorithmSet::Check
			*/
			var i:uint, j:uint;
			
			if(indexes) { //results check
				for(i = 0; i < algParams.length; i += 1) {
					if(!(callParams[indexes[i]] is Variable || callParams[indexes[i]] is ArrayStruct || callParams[indexes[i]] is LValue)) {
						throw new PTypeError(PTypeError.EXPRESSION_NOT_VARIABLE, aexp.line)
					}
				}
			} else {
				indexes = []
				for(j = 0; j < algParams.length; j += 1) {
					indexes.push(j);
				}
			}
			
			for(i = 0; i < indexes.length; i += 1){
				checkExpression(callParams[indexes[i]]);
				setLValue(callParams[indexes[i]], algParams[i], algorithm.name);
				setLValue(algParams[i], callParams[indexes[i]], aexp.algorithm.name);
				
				if(!hasType(callParams[indexes[i]])) {
					if(callParams[indexes[i]] is LValue) {
						if(hasType(algParams[i])) {
							setType(callParams[indexes[i]], algParams[i].type); 
						}
					}
				} else {
					if(!hasType(algParams[i])) {
						setType(algParams[i], callParams[indexes[i]].type)
					}
					if(callParams[indexes[i]].type != algParams[i].type) {
						throw new PTypeError(PTypeError.VARIABLE_TYPE_MISMATCH, aexp.line);
					}
				}
			}
		}
		
		public function checkAlgorithmExpression(exp:AlgorithmExpression):void
		{
			if(!exp.algorithm.data) {
				throw new PTypeError(PTypeError.UNKNOWN_ALGORITHM, exp.line);
			}
			if(exp.params.length != exp.algorithm.data.params.length) {
				throw new PTypeError(PTypeError.PARAM_COUNT_MISMATCH, exp.line);
			}
			
			checkCallParams(exp, exp.params, exp.algorithm.data.params);
			if(exp.algorithm.results.params.length < 1) {
				throw new PTypeError(PTypeError.NULL_ALGORITHM_EXPRESSION, exp.line);
			}
		}
		
		public function checkArrayExpression(ael:ArrayElementExpression):void
		{
			var exp:Expression, dim:uint;
			ael.arrayStruct = ael.arrayStruct.toArray();
			for each (exp in ael.params) {
				checkIndex(exp);
			}
			dim = ael.params.length;
			if(ael.arrayStruct.dimension == 0) {
				ael.arrayStruct.dimension = dim;
			} else {
				if(dim != ael.arrayStruct.dimension) {
					throw new PTypeError(PTypeError.DIMESION_MISMATCH, ael.line);
				}
			}
		}
		
		public function checkIndex(exp:Expression):void
		{
			if (exp.type == 'BOOLEAN' || exp.type == 'STRING') {
				throw new PTypeError(PTypeError.ARRAY_INVALID_INDEX, exp.line);
			}
			if (exp is LValue) {
				setType(exp, 'NUMBER');
			}
		}
		
		public function checkStandardFunction(sfe:StandardFunctionExpression):void
		{
			var param:Expression, t:String, i:uint = 0, pos:int;
			sfe.type = sfe.standardFunction.type;
			if (sfe.params.length != sfe.standardFunction.paramTypes.length) {
				throw new PTypeError(PTypeError.PARAM_COUNT_MISMATCH, sfe.line);
			}
			for(i = 0; i < sfe.params.length; i += 1) {
				t = sfe.standardFunction.paramTypes[i];
				checkExpression(sfe.params[i]);
				setLValueAgainstString(sfe.params[i], t, algorithm.name);
				if (!Checker.areComp(t, sfe.params[i].type)) {
					throw new PTypeError(PTypeError.FUNCTION_PARAMETER_MISMATCH, sfe.line);
				}
				if(param is LValue) {
					setType(param, t);
				}
				i += 1;
			}
		}
		
		public function checkBinary(binary:BinaryExpression):void
		{
			var mode:Object;
			var argMode:uint;
			var argVar:Expression;
			checkExpression(binary.exp1);
			checkExpression(binary.exp2);
			
			if(hasType(binary.exp1)) {
				mode = binary.operator.getMode(binary.exp1.type);
				argMode = 1;
				argVar = binary.exp1;
			} else if(hasType(binary.exp2)) {
				mode = binary.operator.getMode(binary.exp2.type);
				argMode = 2;
				argVar = binary.exp2;
			} else {
				mode = binary.operator.getMode();
				argMode = 0;
				argVar = null;
			}
			if(!mode) {
				throw new PTypeError(PTypeError.OPERATOR_EXPRESSION_MISMATCH, binary.exp1.line);
			}
			binary.type = mode['EXP_CAST'];
			if(argMode == 1) {
				if(!hasType(binary.exp2) && binary.exp2 is LValue) {
					setType(binary.exp2, mode['VAR_CAST']);
				}
			}
			else if(argMode == 2) {
				if(mode && !hasType(binary.exp1) && binary.exp1 is LValue)	{
					setType(binary.exp1, mode['VAR_CAST']);
				}
			}
			else {
				if(mode['VAR_CAST'] != 'VARIABLE') {
					if(binary.exp1 is LValue) {
						setType(binary.exp1, mode['VAR_CAST']);
					}
					if(binary.exp2 is LValue) {
						setType(binary.exp2, mode['VAR_CAST']);
					}
				} else if(binary.exp1 is LValue && binary.exp2 is LValue) {
					bind(binary.exp1, binary.exp2);
				}
			}
			var msg:String;
			if(mode['ACCEPTED_TYPES'].lastIndexOf(binary.exp1.type) == -1) {
				throw new PTypeError(PTypeError.OPERATOR_EXPRESSION_MISMATCH, binary.exp1.line);
			}
			if(mode['ACCEPTED_TYPES'].lastIndexOf(binary.exp2.type) == -1) {
				throw new PTypeError(PTypeError.OPERATOR_EXPRESSION_MISMATCH, binary.exp2.line);
			}
		}
		
		public function checkUnary(unary:UnaryExpression):void
		{
			var mode:Object = unary.operator.getMode(unary.exp.type);
			if(!mode) {
				throw new PTypeError(PTypeError.OPERATOR_EXPRESSION_MISMATCH, unary.exp.line);
			}
			
			unary.type = mode['EXP_CAST'];
			if(!hasType(unary.exp) && unary.exp is LValue && mode['VAR_CAST'] != 'VARIABLE') {
				setType(unary.exp, mode['VAR_CAST']);
			} else {
				checkExpression(unary.exp);
			}
		}
		
		public function setBondedType(l:Object):void
		{
			var s:String = l.name.toLowerCase();
			if(bond.hasOwnProperty(s))	{
				for each(var l1:Object in bond[s]) {
					if(l1.type != l.type) {
						if(hasType(l1 as Expression)) {
							throw new PTypeError(PTypeError.VARIABLE_TYPE_MISMATCH, l1.line);
						} else {
							setType(l1, l.type);
							setBondedType(l1);
						}
					}
				}
			}
			delete bond[s];	
		}
		
		public function bind(l1:Object, l2:Object):void //could either be variable or arrayexpression
		{
			var s1:String = l1.name.toLowerCase();
			var s2:String = l2.name.toLowerCase();
			if(!bond.hasOwnProperty(s1)) {		
				bond[s1] = [];
			}
			if(!bond.hasOwnProperty(s2)) {
				bond[s2] = [];
			}
			bond[s1].push(l2);
			bond[s2].push(l1);
		}
	}
}