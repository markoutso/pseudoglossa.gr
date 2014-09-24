package pseudoglossa
{
	public class PRuntimeError extends PError
	{
		public var line:uint;
		public var object:Object;
		
		private static var messages_:Array;
		
		public static const VARIABLE_NOT_INITIALISED:String = 'Η μεταβλητή χρησιμοποιήθηκε χωρίς να έχει αρχικοποιηθεί';
		public static const ZERO_STEP:String= 'Το βήμα είναι 0';
		public static const NULL_FIRST_OPERAND:String = 'Ο τελεστέος δεν έχει πάρει τιμή';
		public static const NULL_SECOND_OPERAND:String = 'Ο τελεστέος δεν έχει πάρει τιμή';
		public static const NAN_FIRST_OPERAND:String =  'Ο τελεστέος δεν είναι αριθμός';
		public static const NAN_SECOND_OPERAND:String = 'Ο τελεστέος δεν είναι αριθμός';
		public static const DIVISION_BY_ZERO:String = 'Διαίρεση με το 0';
		public static const BOOLEAN_VARIABLE_READ:String = 'Δεν επιτρέπεται το διάβασμα λογικής μεταβλητής';
		public static const ILLEGAL_TYPE_READ:String = 'Η μεταβλητή έχει διαφορετικό τύπο από αυτόν με τον οποίο διαβάστηκε';
		public static const INTERNAL_FUNCTION_ERROR:String = 'Λάθος κατά τον υπολογισμό της συνάρτησης.';
		public static const OPERATOR_ERROR:String = 'Λάθος κατά την εκτέλεση της πράξης.';
		public static const VALUE_NOT_VALID_FOR_INDEX:String = 'Ο δείκτης του πίνακα δεν είναι ακέραιος θετικός αριθμός.';
		public static const END_OF_INPUT_FILE:String = 'Τέλος αρχείου εισόδου. Περίμενα και άλλα δεδομένα.';
		public static const ILLEGAL_ARRAY_DIM_READ:String = 'Λάθος κατά το διάβασμα των διαστάσεων του πίνακα.';
		public static const ARITHMETIC_ERROR:String = 'Λάθος κατά την αποτίμηση της αριθμητικής έκφρασης';
		public static const ARRAY_DIMENSION_ERROR:String = 'Λάθος διάσταση πίνακα';
		public static const ARRAY_INDEX_ERROR:String = 'Ο δείκτης του πίνακα δεν είναι θετικός ακέραιος αριθμός';
		public static const UNKNOWN_TYPE:String = 'Σφάλμα, άγνωστη μεταβλητή';
		
		public function PRuntimeError(message:String, line:uint=0)
		{			
			this.message = message;
			this.line = line;
		}
		public function addToMessage(s:String):void {
			message += s;
		}
		public function toString():String {
			return message;
		}
	}
}