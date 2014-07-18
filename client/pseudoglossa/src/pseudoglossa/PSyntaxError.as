package pseudoglossa
{
	public class PSyntaxError extends PError
	{
		public var token:Token;
		public var line:uint;
		
		public static const EXPECTED_OPERAND:String = 'Περίμενα έκφραση';
		public static const EXPECTED_COMMA:String = 'Περίμενα κόμμα';
		public static const EXPECTED_PAR_LEFT:String = 'Περίμενα αριστερή παρένθεση';
		public static const EXPECTED_PARAMETER:String = 'Περίμενα και άλλη παράμετρο για τη συνάρτηση';
		public static const EXPECTED_PAR_RIGHT:String = 'Περίμενα δεξιά παρένθεση';
		public static const EXPECTED_EOL:String = 'Περίμενα τέλος γραμμής';
	
		public static const EXPECTED_ALGORITHM:String = 'Περίμενα την εντολή "Αλγόριθμος"';
		public static const EXPECTED_END:String = 'Περίμενα την εντολή "Τέλος"';
		public static const EXPECTED_NAME:String = 'Περίμενα όνομα';
		public static const EXPECTED_ALGORITHM_IDENTIFIER:String = 'Περίμενα το όνομα του αλγορίθμου';
		public static const MISSING_COMMA_IN_ARRAY_INDEX:String = 'Λείπει κόμμα στον δείκτη του πίνακα';
		public static const ERROR_PARSING_ARRAY_INDEX:String	= 'Λάθος κατά την ανάγνωση δείκτη πίνακα';
		public static const EXPECTED_CHAR:String = 'Περίμενα το χαρακτήρα';
		public static const EXCEEDED_MAX_ARRAY_DIM:String = 'Ξεπεράστηκε η μέγιστη διάσταση πίνακα';
		public static const EXPECTED_DS:String = 'Περίμενα το σύμβολο "//"';
		public static const INVALID_DATA_POS:String = 'Η εντολή "Δεδομένα" μπορεί να μπει μόνο μια φορά και αμέσως μετά την εντολή "Αλγόριθμος [όνομα]"';
		public static const INVALID_RESULTS_POS:String = 'Η εντολή "Αποτελέσματα" μπορεί να μπει μόνο μόνο μια φορά και πριν εντολή "Τέλος';
		public static const EXPECTED_READ:String = 'Περίμενα την εντολή Διάβασε';
		public static const EXPECTED_WRITE:String = 'Περίμενα την εντολή Εμφάνισε';
		public static const EXPECTED_ASSIGNMENT:String = 'Περίμενα την εντολή εκχώρησης';
		public static const EXPECTED_IDENTIFIER_NOT_ARR:String = 'Περίμενα αναγνωριστικό χωρίς αγκύλες';
		public static const EXPECTED_THEN:String = 'Περίμενα τη δεσμευμένη λέξη "τότε"';
		public static const EXPECTED_END_IF:String = 'Περίμενα την εντολή "Tέλος_Αν"';
		public static const EXPECTED_WHILE_BEGIN:String = 'Περίμενα την εντολή "Επανάλαβε"';
		public static const EXPECTED_END_LOOP:String = 'Περίμενα την εντολή "Τέλος_Επανάληψης"';
	
		public static const EXPECTED_CASE:String = 'Περίμενα την εντολή "Περίπτωση"';
		public static const EXPECTED_END_SELECT:String = 'Η εντολή "Επίλεξε" δεν μπορεί να έχει άλλες περιπτώσεις μετά την "Περίπτωση Αλλιώς"';
	
		public static const EXPECTED_FOR_START:String = 'Περίμενα την εντολή "από"';
		public static const EXPECTED_FOR_END:String = 'Περίμενα την εντολή "μέχρι"';
		public static const EXPECTED_STEP:String = 'Περίμενα την εντολή "με_βήμα"';
		public static const EXPECTED_VARIABLE:String = 'Περίμενα μεταβλητή';
	
		public static const UNEXPECTED_END:String = 'Απρόσμενο τέλος';
		public static const LAST_OPEN_STATEMENT:String = 'Τελευταία ανοιχτή εντολή';
		public static const UNEXPECTED_STATEMENT:String = 'Δεν περίμενα εδώ το ';
		public static const NO_EXISTENT_FUNCTION:String = 'Δεν υπάρχει αυτή η συνάρτηση';
		public static const SYMBOL_USED_AS_VARIABLE:String = 'Η μεταβλητή χρησιμοποιήθηκε σαν πίνακας ενώ έχει ήδη χρησιμοποιηθεί σαν απλή μεταβλητή';
		public static const SYMBOL_USED_AS_ARRAY:String = 'Η μεταβλητή είναι όνομα πίνακα αλλά χρησιμοποιείται χωρίς δείκτες';
		public static const ARRAY_DIMENSION_DIFFERENCE:String = 'Ο πίνακας έχει χρησιμοποιηθεί με διαφορετικό αριθμό διαστάσεων';
	
		public static const INVALID_IDENTIFIER:String = 'Μη αποδεκτό όνομα μεταβλητής';
		public static const INVALID_BOOLEAN_EXPRESSION:String = 'Οι λογικές εκφράσεις μπορούν να χρησιμοποιηθούν μόνο με τους τελεστές "=" και "<>"';
		
		public static const ALGORITHM_ENDED:String = 'Ο αλγόριθμος τελείωσε, δεν περίμενα άλλες εντολές';
		public static const EXPECTED_CLS:String = 'Περίμενα την εντολή Καθάρισε';

		public function PSyntaxError(message:String, token:Token)
		{
			this.message = message;
			this.token = token;
			this.line = token.line;
		}
		
		public function toString():String 
		{
			var s:String = 'Συντακτικό Λάθος - ' + message + '\n';
			var v:String = token.specKey ? token.specKey.key : token.key;
			if(v == '@EOL') 
				v = 'τέλος γραμμής';
			else if( v == '@EOF')
				v = 'τέλος αρχείου';
			else 
				s += 'Βρήκα : ' + v + '\n';
			return s; 
		}

	}
}
