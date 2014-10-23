package pseudoglossa
{
	public class PTypeError extends PError
	{
		public var line:uint;
		
		public static const ARRAY_INVALID_INDEX:String = 'Ο δείκτης του πίνακα δεν είναι ακέραιος θετικός αριθμός';
		public static const CONDITION_ERROR:String = 'Η συνθήκη δεν είναι έγκυρη';
		public static const NUMBER_ERROR:String = 'Περίμενα αριθμητική έκφραση';
		public static const FUNCTION_PARAMETER_MISMATCH:String  = 'Σφάλμα κατά την αντιστοιχιση παραμέτρου';
		public static const OPERATOR_EXPRESSION_MISMATCH:String = 'Ο τελεστής δεν μπορεί να χρησιμοποιηθεί με την συγκεκριμένη έκφραση';
		public static const SELECT_SELECTOR_ERROR:String = 'Η μεταβλητή στην έκφραση δεν έχει τον ίδιο τύπο με τον επιλογέα';
		public static const SELECT_CASE_EXPRESSION_ERROR:String = 'Οι εκφράσεις της περίπτωσης είναι διαφορετικού τύπου';
		public static const SWAP_VARIABLE_MISMATCH:String = 'Οι μεταβλητές στην εντολή αντιμετάθεσε έχουν διαφορετικό τύπο';
		public static const VARIABLE_TYPE_MISMATCH:String = 'Η μεταβλητή έχει διαφορετικό τύπο από αυτόν με τον οποίο χρησιμοποιείται στην συγκεκριμένη εντολή';
		public static const PARAM_COUNT_MISMATCH:String = 'Λάθος αριθμός ορισμάτων για την κλήση';
		public static const DUPLICATE_ALGORITHM_DECLARATION:String = 'Δύο αλγόριθμοι δεν μπορούν να έχουν το ίδιο όνομα';
		public static const UNKNOWN_ALGORITHM:String = 'Κλήση σε άγνωστο αλγόριθμο';
		public static const DIMESION_MISMATCH:String = 'Ο πίνακας έχει διαφορετικό αριθμό διαστάσεων';
		public static const EXPRESSION_NOT_VARIABLE:String = 'Η έκφραση δεν είναι μεταβλητή.';
		public static const NULL_ALGORITHM_EXPRESSION:String = 'Η κλήση σε αλγόριθμο δεν επιστρέφει κάποια τιμή';
		public static const EXPRESSION_NOT_ARRAY:String = 'Η έκφραση δεν είναι πίνακας';
		public static const VARIABLE_NOT_ARRAY:String = 'Η μεταβλητή δεν είναι πίνακας';
		public static const VARIABLE_IS_ALORITHM_NAME:String = 'Η μεταβλητή έχει το ίδιο όνομα με τον αλγόριθμο';

		
		public function PTypeError(message:String, line:uint)
		{
			this.message = message;
			this.line = line;
		}
		public function toString():String {
			return message;
		}
		
	}
}