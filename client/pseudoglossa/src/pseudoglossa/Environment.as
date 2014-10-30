package pseudoglossa
{	
	import flash.utils.*;
	
	import json.JSON;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class Environment	
	{
		public var code:String;
		public var set:AlgorithmSet;
		public var statementsExecuted:uint;
		public var delay:uint;
		public var commands:Array;
		public var lines:Array;
		public var pc:uint;
		public var intervalID:uint;
		public var brokeAt:uint = 0;
		public var executionArea:IExecutionArea;
		public var ended:Boolean;
		public var systemIn:IInput;
		public var systemOut:IOutput;
		public var app:Application;
		public var halted:Boolean;
		public var outputLog:String;
		public var inputStatement:Statement;
		public var executeMode:uint;
		public var executedCommandsCount:uint;
		
		public static const COMMANDS_WARNING_LIMIT:uint = 100000;
		public var commandsWarned:Boolean;
		public static const MODE_RUN:uint = 1;
		public static const MODE_STEP:uint = 2;
		public static const MODE_INTERVAL:uint = 3;
		public static const RESUME_READ:uint = 4;
		public static const RESUME_DATA:uint = 5;
		public static const EVENTS:Array = ['start', 'completed', 'stack', 'step', 'break', 'stop', 'run'];
		
		
		public var listeners:Object;		
		public var _lastError:Object = {};
		public var callStack:Stack;
		public var minutes:uint = 0;
		public var alert:Alert;
		
		public static var instance:Environment;
		
		public function Environment(app:Application, systemOut:IOutput, systemIn:IInput, executionArea:IExecutionArea = null)
		{
			this.app = app;
			this.executionArea = executionArea;
			if(executionArea) {
				this.executionArea.setEnvironment(this);
			}			
			this.systemIn = systemIn;
			this.systemIn.setEnvironment(this);
			this.systemOut = systemOut;
			this.delay = 0;
			this.listeners = {};
			for each (var k:String in EVENTS) {
				this.listeners[k] = new Dictionary();
			}
			this.callStack = new Stack();
			if(!instance) {
				instance = this;
			} else {
				throw new Error('only one environment instance is allowed');
			}
		}
		
		public function executionInfo():String
		{
			var f:Frame, t:Array = [];
			for (var i:int = callStack.arr.length - 1; i >= 0; i -= 1) {
				f = callStack.arr[i] as Frame;
				t.push({
					name: f.algorithm.name, 
					returnLine: lines[f.returnIndex], 
					symbolTable: f.symbolTable.flatten()					
				});
			}
			return JSON.encode({currentLine: lines[pc], callStack: t, output: outputLog});
		}
		
		public function trigger(event:String):void
		{
			for each(var f:Function in listeners[event]) {
				f();
			}
		}
		
		public function subscribe(event:String, fn:Function):void
		{
			listeners[event][fn] = fn;
		}
		
		public function unsubscribe(event:String, fn:Function):void
		{
			delete listeners[event][fn];			
		}
		
		public function setSystemIn(si:IInput):void
		{
			si.setEnvironment(this);
			systemIn = si;
		}
		public function setSystemOut(so:IOutput):void
		{
			systemOut = so;
		}
		public function get symbolsCollection():ArrayCollection 
		{
			return frame.symbolTable.collection;
		}
		public function get currentLine():uint 
		{
			return lines[pc];
		}
		public function get length():uint 
		{
			return lines.length;
		}
		public function advancePC(n:uint = 1):void 
		{
			pc += n;
		}
		public function setPC(n:uint):void 
		{
			pc = n;
		}
		public function reducePC():void 
		{
			pc -= 1;
		}
		public function addCommand(f:Function, line:uint=0):void 
		{
			commands.push(f);
			lines.push(line);
		}
		
		public function addCommands(commands:Array):void
		{
			for each(var arr:Array in commands) {
				commands.push(arr[0]);
				lines.push(arr[1]);
			}
		}
		
		public function stepIn():void 
		{	
			executeMode = MODE_STEP;
			if(pc < commands.length) {
				executeCommand();
			}
		}
		public function stepOut():void 
		{	
			executeMode = MODE_STEP;
			var fi:uint = frame.index, line:uint = lines[pc];
			if(pc < commands.length) {
				executeCommand();
			}
			if(pc >= commands.length) {
				stop();
			} else {
				while(callStack.length > 0 && frame.returnIndex > 0 && frame.index >= fi && pc < commands.length) {
					executeCommand();
				}
			}
		}
		public function stepNext():void 
		{	
			executeMode = MODE_STEP;
			var fi:uint = frame.index, line:uint = lines[pc];
			if(pc < commands.length) {
				executeCommand();
			}
			if(pc >= commands.length) {
				stop();
			} else {
				while(callStack.length > 0 && frame.returnIndex > 0 && frame.index > fi && pc < commands.length) {
					executeCommand();
				}
			}
		}
		public function executeCommand():void 
		{
			var f:Function = commands[pc];
			var l:uint = lines[pc];
			try {
				f()
			}
			catch(e:PRuntimeError) {
				handleRuntimeError(e, l);
				return;
			}
			executedCommandsCount++;
			brokeAt = 0;
			l = lines[pc];
			if(!halted && !ended && executeMode != MODE_RUN && l != 0) {
				executionArea.executeLine(l);
				trigger('step');
			}
			if(!commandsWarned && executedCommandsCount > COMMANDS_WARNING_LIMIT) {
				commandsWarned = true;
				notice('Εκτελέστηκαν μέχρι στιγμής ' + COMMANDS_WARNING_LIMIT.toString() + 
					' εντολές. Θέλετε να διακόψετε προσωρινά την εκτέλεση του αλγορίθμου;');
			}
		}
		public function notice(message:String):void 
		{
			halt();
			alert = Alert.show(message, 'Μήνυμα διερμηνευτή', Alert.OK | Alert.NO, null, 
				function(e:CloseEvent):void {
					if(e.detail != Alert.OK) {
						resume();
					} else { 
						halted = false;
					}
				}
			);
		}
		public function doStep():void 
		{
			if(checkBreakpoint() || delay == 0 || halted) {
				clearStepInterval();
				return;
			}
			executeCommand();
			if(pc >= commands.length)	{
				stop();
				clearStepInterval();
			}
		}
		public function clearStepInterval():void 
		{
			clearInterval(intervalID);
			intervalID = 0;
		}
		public function setStepInterval():void 
		{
			executeMode = MODE_INTERVAL;
			intervalID = setInterval(doStep, delay);
		}
		public function brokeAtCurrentLine():Boolean 
		{
			return brokeAt == lines[pc];
		}
		public function breakAtCurrentLine():Boolean 
		{
			return executionArea.hasBreakpoint(lines[pc]);
		}		
		public function run():void 
		{
			if(delay == 0) {
				try {
					executeMode = MODE_RUN;
					while(pc < commands.length && !halted && !ended) {
						if(checkBreakpoint()) {
							return;
						}
						executeCommand();
				 	}
				} catch (e:Error) {					
					if(e.errorID == 1502) {
						minutes += 1;
						var m:String = minutes == 1 ? 'λεπτό' : 'λεπτά';
						notice("Ο αλγόριθμος εκτελείται για " + minutes + " " + m + " (όριο του flash player). Θέλετε να διακόψετε προσωρινά την εκτέλεσή του;");
					}
				}
			}
			else {
				setStepInterval();
			}
		}
		public function checkBreakpoint():Boolean 
		{
			if(breakAtCurrentLine() && !brokeAtCurrentLine()) {
		 		executionArea.executeLine(lines[pc]);
		 		brokeAt = lines[pc];
				trigger('break');
		 		return true;
		 	}
		 	return false;
		}
		public function start(code:String):Boolean 
		{			
			commands = [];
			lines = [];
			pc = 0;
			ended = false;
			halted = false;
			outputLog = '';
			commandsWarned = false;
			executedCommandsCount = 0;
			minutes = 0;
			callStack.reset();
			systemOut.clear();
			_lastError = {};
			if(!checkSet(code)) {
				return false;
			}
			try {
				callStack.push(new Frame(set.main));
			} catch(e:*) {
				if(e is PError) {
					handleError(e, e.line);
					return false;
				}
				throw e;
			}
			set.createSteps();
			executionArea.startExecution();
			executionArea.executeLine(lines[0]);
			trigger('start');
			return true;
		}		
		
		public function get frame():Frame
		{
			return callStack.top as Frame;
		}
		
		public function get parentFrame():Frame
		{
			if(callStack.length < 2) { 
				return null;
			}
			return callStack.getItemAt(callStack.length - 2) as Frame;
		}
		
		public function call(frame:Frame):void
		{
			callStack.push(frame);
			trigger('stack');
			setPC(frame.algorithm.startIndex + 1);
		}

		public function ret():void
		{
			frame.copyOut();
			pc = frame.returnIndex;
			callStack.pop();
			if(pc == 0) {
				stop();
			} else {
				trigger('stack');
			}
		}
		
		public function checkSet(code:String):AlgorithmSet
		{
			try {
				set = new AlgorithmSet(code);
				set.prepare();
				set.check();
			} catch(e:*) {
				if(e.hasOwnProperty('line')) {
					handleError(e, e.line);
				} else {
					handleError(e, 0);
				}
				return null;
			}
			return set;
		}
		public function stop(fromUser:Boolean=false):void 
		{
			if(!ended) {
				executionArea.stopExecution();
				if(intervalID) {
					clearStepInterval();
				}		
				if (alert) {
					PopUpManager.removePopUp(alert);
				}
				app.setFocus();
				systemOut.stop();
				systemIn.stop();
				ended = true;
				halted = false;
				callStack.reset();
				if (fromUser) {
					trigger('stop');
				} else {
					trigger('completed');
				}
			}
		}
		public function handleRuntimeError(e:Error, line:uint):void
		{
			stop();
			handleError(e, line);
		}
		public function handleError(e:Error, line:uint):void
		{
			var type:String = e is PRuntimeError ? 'runtime' : 'syntax';
			_lastError = {
				type : type,
				line : line,
				message : e.message
			};
			//ended = true;
			stop();
			executionArea.showError(e, line);
			systemOut.writeError(e.toString());
			throw e;
		}
		public function get lastError():Object 
		{
			return _lastError;
		}
		public function halt():void 
		{
			halted = true;
			if(executeMode == MODE_INTERVAL) {
				clearStepInterval();
			}
		}
		public function resume(reason:uint = 0):void 
		{
			halted = false;
			executionArea.executeLine(lines[pc]);
			if(executeMode == MODE_INTERVAL) {
				setStepInterval();
			}
			else if(executeMode == MODE_RUN) {
				run();
			}
		}
		public function get inputLog():String
		{
			return systemIn.inputLog();
		}
		public function input(callback:Function, l:LValue):void 
		{
			executionArea.executeLine(lines[pc]);
			systemIn.read(callback);
		}
		public function results(s:String):void 
		{
			outputLog += s;
			systemOut.results(s);
		}
		public function inputData(callback:Function, lv:LValue):void 
		{
			executionArea.executeLine(lines[pc]);
			systemIn.inputData(callback, lv);
		}
		public function output(s:String):void 
		{
			outputLog += s;
			systemOut.write(s);
		}
	}
}

