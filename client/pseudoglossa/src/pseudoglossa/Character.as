package pseudoglossa
{
	public class Character
	{
		public static var spaceRegExp:RegExp = /\s/;
		public static var newLineRegExp:RegExp = /\n|\r/;

		public static function isSpace(c:String):Boolean {			
			return spaceRegExp.test(c);
		}
		public static function isGreek(c:String):Boolean {
			return c >= 'Ά' && c <= 'ώ';
		}
		
		public static function isEnglish(c:String):Boolean{
			return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
		}
		public static function isLetter(c:String):Boolean{
			return Character.isGreek(c) || Character.isEnglish(c);
		}
		public static function isWordChar(c:String):Boolean {
			return Spec.isWordChar(c);
		}
		public static function isDigit(c:String):Boolean {
			return c >= '0' && c <= '9';
		}
		public static function isNewLine(c:String):Boolean {			
			//return newLineRegExp.test(c);
			return c == '\r' || c == '\n' || c == '\r\n';
		}
	}
}
