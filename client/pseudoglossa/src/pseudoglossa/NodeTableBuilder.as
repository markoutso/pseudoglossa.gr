package pseudoglossa
{
	public class NodeTableBuilder
	{
		public var algorithm:AlgorithmStatement;
		public var nt:NodeTable;
		public var callExps:Array;
		public var lvalues:Object;
		
		public function NodeTableBuilder(algorithm:AlgorithmStatement, nt:NodeTable)
		{
			this.algorithm = algorithm;
			this.nt = nt;
			this.callExps = [];
			this.lvalues = {};
		}

		public function build():void
		{
			nt.set(algorithm.name, algorithm);
			buildStatements(algorithm.statements);
		}
		
		public function regLValue(lvalue:LValue, parent:Object, prop:String, index:int = -1):void
		{
			if(!lvalues.hasOwnProperty(lvalue.name)) {
				lvalues[lvalue.name] = [];
			}
			lvalues[lvalue.name].push({parent: parent, prop:prop, index: index});
		}
		
		public function updateLValue(l:LValue):void
		{
			for each(var obj:Object in lvalues[l.name]) {
				if(obj.index != -1) {
					obj.parent[obj.prop][obj.index] = l;
				} else {
					obj.parent[obj.prop] = l;
				}
			}
		}
		
		public function buildStatements(statements:Array):void
		{
			for each(var st:Statement in statements) {
				buildStatement(st);
			}
		}
		
		public function buildStatement(st:Statement):Object
		{
			if(st is DataStatement) {
				return buildData(st as DataStatement);
			} else if(st is ReadStatement) {
				return buildRead(st as ReadStatement);
			} else if(st is AssignmentStatement) {
				return buildAssignment(st as AssignmentStatement);
			} else if(st is IfStatement) {
				return buildIf(st as IfStatement);
			} else if(st is SelectStatement) {
				return buildSelect(st as SelectStatement);
			} else if(st is WhileStatement) {
				return buildWhile(st as WhileStatement);
			} else if(st is RepeatStatement) {
				return buildRepeat(st as RepeatStatement);
			} else if(st is ForStatement) {
				return buildFor(st as ForStatement);
			} else if(st is SwapStatement) {
				return buildSwap(st as SwapStatement);
			} else if(st is WriteStatement) {
				return buildWrite(st as WriteStatement);
			} else if(st is ResultsStatement) {
				return buildResults(st as ResultsStatement);
			} else if(st is CallStatement) {
				return buildCall(st as CallStatement);
			}
			return st;
		}
		
		public function buildCall(call:CallStatement):CallStatement
		{
			buildAlgorithmExpression(call.exp);
			return call;
		}
		
		public function buildResults(results:ResultsStatement):ResultsStatement
		{
			for(var i:uint = 0; i < results.params.length; i += 1) {
				if(results.params[i].type == 'LVALUE') {
					regLValue(results.params[i], results, 'params', i)
				}
				results.params[i] = buildExpression(results.params[i]);
			}
			return results;
		}
		
		public function buildWrite(write:WriteStatement):WriteStatement
		{
			for(var i:uint = 0; i < write.params.length; i += 1) {
				write.params[i] = buildExpression(write.params[i]);
			}
			return write;
		}
		
		public function buildSwap(swap:SwapStatement):SwapStatement
		{
			swap.lvalue1 = buildLValue(swap.lvalue1);
			swap.lvalue2 = buildLValue(swap.lvalue2);
			return swap;
		}
		
		public function buildFor(forstat:ForStatement):ForStatement
		{
			
			forstat.lvalue = buildExpression(forstat.lvalue) as LValue;
			forstat.start = buildExpression(forstat.start);
			forstat.end = buildExpression(forstat.end);
			forstat.step = buildExpression(forstat.step);
			buildStatements(forstat.statements);
			return forstat;
		}
		
		public function buildRepeat(repeat:RepeatStatement):RepeatStatement
		{
			repeat.condition = buildExpression(repeat.condition);
			buildStatements(repeat.statements);
			return repeat;
		}
		
		public function buildWhile(whilest:WhileStatement):WhileStatement
		{
			whilest.condition = buildExpression(whilest.condition);
			buildStatements(whilest.statements);
			return whilest;
		}
		
		public function buildSelect(select:SelectStatement):SelectStatement
		{
			select.selector = buildExpression(select.selector);
			for each(var casest:CaseStatement in select.statements) {
				buildCase(casest);
			}
			return select;
		}
		
		public function buildCase(casest:CaseStatement):CaseStatement
		{
			for each(var caseExp:CaseExpression in casest.expressions) {
				buildCaseExp(caseExp);
			}
			buildStatements(casest.statements);
			return casest;
		}
		
		public function buildCaseExp(caseExp:CaseExpression):CaseExpression
		{			
			if(!caseExp.isElse) {
				if(caseExp.exp1) {
					caseExp.exp1 = buildExpression(caseExp.exp1);
				}
				if(caseExp.exp2) {
					caseExp.exp2 = buildExpression(caseExp.exp2);
				}
			}
			return caseExp;
		}
		
		public function buildIf(ifstat:IfStatement):IfStatement
		{
			ifstat.condition = buildExpression(ifstat.condition);
			for each(var st:Statement in ifstat.statements) {
				buildStatement(st);
			}
			for each (var elseif:ElseIfStatement in ifstat.elseIfStatements)  {
				elseif.condition = buildExpression(elseif.condition);
				buildStatements(elseif.statements);
			}
			buildStatements(ifstat.elseStatements);
			return ifstat;
		}
		
		public function buildExpression(exp:Expression):Expression
		{
			if(exp is LValue) {
				return buildLValue(exp as LValue);
			} else if(exp is UnaryExpression) {
				return buildUnaryExpression(exp as UnaryExpression);
			} else if(exp is BinaryExpression) {
				return buildBinaryExpression(exp as BinaryExpression);
			} else if(exp is AlgorithmExpression) {
				return buildAlgorithmExpression(exp as AlgorithmExpression);
			} 
			return exp;
		}
		
		public function buildArrayElementExpression(exp:ArrayElementExpression):ArrayElementExpression
		{
			exp.arrayStruct.dimension = exp.params.length;
			exp.arrayStruct = nt.setCheckArray(exp.arrayStruct);
			for(var i:uint = 0; i < exp.params.length; i += 1) {
				exp.params[i] = buildExpression(exp.params[i]);
			}
			return exp;
		}
		
		public function buildAlgorithmExpression(exp:AlgorithmExpression):*
		{
			var sf:StandardFunction = StandardFunction.getStandardFunction(exp.algorithm.name);
			if(sf) {
				var sfe:StandardFunctionExpression = new StandardFunctionExpression(sf, exp.params);
				sfe.line = exp.line;
				callExps.push(sfe);
				return buildStandardFunctionExpression(sfe);
			} else {
				callExps.push(exp);
				exp.algorithm = Environment.instance.set.getAlgorithm(exp.algorithm.name) || exp.algorithm;
				for(var i:uint = 0; i < exp.params.length; i += 1) {
					exp.params[i] = buildExpression(exp.params[i]);
					if(exp.params[i] is LValue && exp.params[i].type == 'LVALUE' ) {
						regLValue(exp.params[i], exp, 'params', i);
					}
				}
				return exp;
			}
		}
		
		public function buildStandardFunctionExpression(exp:StandardFunctionExpression):StandardFunctionExpression
		{
			for(var i:uint = 0; i < exp.params.length; i += 1) {
				if(exp.params[i].type == 'LVALUE') {
					regLValue(exp.params[i], exp, 'params', i);
				}
				exp.params[i] = buildExpression(exp.params[i]);
			}
			return exp;
		}
		
		public function buildBinaryExpression(exp:BinaryExpression):BinaryExpression
		{
			exp.exp1 = buildExpression(exp.exp1);
			exp.exp2 = buildExpression(exp.exp2);
			return exp;
		}
		
		public function buildUnaryExpression(exp:UnaryExpression):UnaryExpression
		{
			exp.exp = buildExpression(exp.exp);
			return exp;
		}
		
		public function buildAssignment(assign:AssignmentStatement):AssignmentStatement
		{
			if(assign.lvalue.type == 'LVALUE') {
				regLValue(assign.lvalue, assign, 'lvalue');
			}
			assign.lvalue =	buildLValue(assign.lvalue);
			assign.expression = buildExpression(assign.expression);
			return assign;
		}
		
		public function buildLValue(lvalue:LValue):LValue
		{
			if(lvalue is Variable) {
				return nt.setCheckVar(lvalue as Variable);
			} else if(lvalue is ArrayStruct) {
				return nt.setCheckArray(lvalue as ArrayStruct);
			} else if(lvalue is ArrayElementExpression){
				return buildArrayElementExpression(lvalue as ArrayElementExpression) as LValue;
			} else {
				return nt.setCheckLValue(lvalue);
			}
		}
		
		public function buildRead(read:ReadStatement):ReadStatement
		{
			for(var i:uint = 0; i < read.params.length; i += 1) {
				read.params[i] = buildLValue(read.params[i]);
			}
			return read;
		}
		
		public function buildData(ds:DataStatement):DataStatement
		{
			for(var i:uint = 0; i < ds.params.length; i += 1) {
				if(ds.params[i].type == 'LVALUE') {
					regLValue(ds.params[i], ds, 'params', i);
				}
				ds.params[i] = buildLValue(ds.params[i]);
			}
			return ds;
		}

	}
}