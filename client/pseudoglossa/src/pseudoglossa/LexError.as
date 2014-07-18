package pseudoglossa
{
	public class LexError extends PError
	{
		public static const ERROR_PARSING_NUMBER:String = 'Λάθος κατά την ανάγνωση αριθμού';
		public static const EXPECTED_END_OF_QUOTE:String = 'Περίμενα το χαρακτήρα ';
		public static const INVALID_INPUT:String = 'Άκυρος χαρακτήρας';
		public var line:uint;
		
		public function LexError(msg:String, line:uint)	{
			this.message = msg;
			this.line = line;			
		}
		public function toString():String{
			return 'Συντακτικό Λάθος - ' + message;
		}
	}
}
