package pseudoglossa
{
	public interface IExecutionArea
	{
		function startExecution():void;
		function stopExecution():void;
		function executeLine(lineIndex:uint):void;
		function hasBreakpoint(lineIndex:uint):Boolean;	
		function setEnvironment(env:Environment):void;	
		function showError(e:Error, line:uint):void;
		function breakPoints():Array;
		function setBreakPoint(line:uint, unset:Boolean):void;
	}
}