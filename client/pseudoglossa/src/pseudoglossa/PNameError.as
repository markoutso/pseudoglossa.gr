package pseudoglossa
{
	public class PNameError extends PError
	{
		public var line:uint;
		
		public static const NAME_TYPE_NOT_COMPATIBLE:String = 'Το όνομα αυτό έχει χρησιμοποιηθεί για διαφορετική κατηγορία έκφρασης.';
		
		public function PNameError(message:String, line:uint)
		{
			this.message = message;
			this.line = line;
		}
		public function toString():String {
			return this.message;
		}
		
	}
}