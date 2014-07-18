package pseudoglossa
{
	public interface IInput
	{
		function setEnvironment(env:Environment):void;
		function read(callback:Function):void;
		function stop():void;
		function inputData(callback:Function, lv:LValue):void;
		function inputLog():String;
	}
}