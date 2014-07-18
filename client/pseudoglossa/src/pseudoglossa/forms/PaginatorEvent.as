package pseudoglossa.forms
{
	import flash.events.Event;
	
	public class PaginatorEvent extends Event
	{
		public static const PAGE_CLICKED:String = 'pageClicked';
		public var pageClicked:Number;
		
		public function PaginatorEvent(bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(PAGE_CLICKED, bubbles, cancelable);
		}
	}
}