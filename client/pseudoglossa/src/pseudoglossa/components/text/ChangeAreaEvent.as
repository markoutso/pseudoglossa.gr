package pseudoglossa.components.text
{
	import flash.events.Event;
	
	public class ChangeAreaEvent extends Event
	{
		public static const CHANGE_AREA:String = 'changeArea';
		public var area:Array;
		
		public function ChangeAreaEvent(type:String, area:Array, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.area = area;
			super(CHANGE_AREA, bubbles, cancelable);
		}
	}
}