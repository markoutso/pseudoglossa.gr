package pseudoglossa.components.text
{
	import flight.commands.IUndoableCommand;
	
	public interface IUndoableTextCommand extends IUndoableCommand
	{
		function get undoSpan():Array;		
		function get redoSpan():Array;
	}
}