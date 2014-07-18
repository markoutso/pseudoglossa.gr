package pseudoglossa
{
	public class Helper {
		public static const THROW_ERRORS:Boolean = true;
		public static const SUPRESS_ERRORS:Boolean = false;
		public static var reading:Boolean = false;
		public static var Settings:Object;
		
		private static var trimPattern:RegExp = /\s/;
		
		public static function setSettings(settings:Object):void {
			Settings = settings;
		}

		public static function round(n:Number, digits:uint = 3):Number 
		{
			return (
					Math.round(
						n * Math.pow(10, digits)
					) / Math.pow(10, digits)
				);		
		}
		public static function trunc(s:String, digits:uint = 3):String 
		{
			return (
					Math.floor(
						parseFloat(s) * Math.pow(10, digits)
					) / Math.pow(10, digits)
				).toString();
		}
		public static function strRepeat(s:String, times:uint):String 
		{
			var r:String = '';
			for(var i:uint = 0; i < times; i++)
				r += s;
			return r;
		}
		public static function formatDateTime(value:String):String 
		{
			var arr:Array = value.split(' ');
			return arr[0].split('-').reverse().join('-') +' ' + arr[1];			
		}
		public static function formatDate(value:String):String 
		{
			var arr:Array = value.split(' ');
			return arr[0].split('-').reverse().join(' ');
		}
		public static function escapeCode(text:String):String 
		{
			return text.replace(/</g, '&lt;').replace(/>/g, '&gt;');
		}
		public static function trimLeft(s:String):String 
		{			
			var i:uint = 0;
			var l:uint = s.length;
			while(s.charAt(i).match(trimPattern) && i < l) {
				i += 1;
			}
			return s.substr(i);
		}
		public static function trimRight(s:String):String 
		{
			var i:uint = s.length - 1;
			while(s.charAt(i).match(trimPattern) && i > 0) {
				i -= 1;
			}
			return s.substring(0, i + 1);
		}
		public static function trim(s:String):String 
		{
			return trimRight(trimLeft(s));
		}
	}
}