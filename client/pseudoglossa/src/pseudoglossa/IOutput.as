package pseudoglossa
{
	public interface IOutput
	{
		function write(s:String):void;
		function writeError(s:String):void;
		function print(s:String):void;
		function results(s:String):void;
		function stop():void;
		function clear():void;
	}
}