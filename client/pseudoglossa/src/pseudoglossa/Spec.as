package pseudoglossa
{
	
	public class Spec
	{
		public static var tokens:Array = [
			['^','@EXP','OPERATORS',false],
			['+','@ADD','OPERATORS',false],
			['–','@SUB','OPERATORS',false],   //unichr[45)
			['-','@SUB','OPERATORS',false],   // unichr[8211)
			['*','@MUL','OPERATORS',false],
			['/','@DIV','OPERATORS',false],

			['div','@EDIV','OPERATORS',true],
			['mod','@EMOD','OPERATORS',true],	
			
			
			['διω','@EDIV','OPERATORS',true],
			['μοδ','@EMOD','OPERATORS',true],	

			['<=','@LE','OPERATORS',false],
			['≤','@LE','OPERATORS',false],
			['>=','@GE','OPERATORS',false],
			['≥','@GE','OPERATORS',false],
			['<>','@NE','OPERATORS',false],
			['≠','@NE','OPERATORS',false],
			['>','@GT','OPERATORS',false],
			['<','@LT','OPERATORS',false],
			['=','@EQ','OPERATORS',false],

			['ή','@OR','OPERATORS',true],
			['και','@AND','OPERATORS',true],

			['όχι','@NOT','OPERATORS',true],
			['–','@MINUS','OPERATORS',false],
			['-','@MINUS','OPERATORS',false],//argg11$#@%^$#
			['+','@PLUS','OPERATORS',false],

			['Αλλιώς','@ELSE','KEYWORDS'],
			['Αλλιώς_Αν','@ELSE_IF','KEYWORDS'],
			['Αλγόριθμος','@ALGORITHM','KEYWORDS'],
			['Αντιμετάθεσε','@SWAP','KEYWORDS'],
			['Αν','@IF','KEYWORDS'],
			['από' ,'@FOR_START','KEYWORDS'],
			['Αποτελέσματα','@RESULTS', 'KEYWORDS'],
			['Αρχή_επανάληψης','@DO', 'KEYWORDS'],
			['Εμφάνισε','@WRITE','KEYWORDS'],
			['Εκτύπωσε','@WRITE','KEYWORDS'],
			['Γράψε','@WRITE','KEYWORDS'],
			['Για','@FOR','KEYWORDS'],
			['Διάβασε','@READ','KEYWORDS'],
			['Καθάρισε', '@CLS', 'KEYWORDS'],
			['Δεδομένα','@DATA','KEYWORDS'],
			['επανάλαβε','@REPEAT','KEYWORDS'],
			['Επίλεξε','@SELECT','KEYWORDS'],
			['Κάλεσε', '@CALL', 'KEYWORDS'],
			['με_βήμα','@STEP','KEYWORDS'],
			['μέχρι','@FOR_END','KEYWORDS'],
			['Μέχρις_Ότου','@UNTIL','KEYWORDS'],
			['Περίπτωση','@CASE','KEYWORDS'],
			['Όσο','@WHILE','KEYWORDS'],
			['Τέλος','@END','KEYWORDS'],
			['Τέλος_Αν','@END_IF','KEYWORDS'],
			['Τέλος_Επανάληψης','@END_LOOP','KEYWORDS'],
			['Τέλος_Επιλογών','@END_SELECT','KEYWORDS'],
			['τότε','@THEN','KEYWORDS'],
		
			['<-', '@ASSIGN','SYMBOLS'],
			['←', '@ASSIGN','SYMBOLS'],
			['⟵', '@ASSIGN','SYMBOLS'],
			['(','@PAR_LEFT','SYMBOLS'],
			[')','@PAR_RIGHT','SYMBOLS'],
			['[','@ARRAY_LEFT','SYMBOLS'],
			[']','@ARRAY_RIGHT','SYMBOLS'],
			[',','@COMMA','SYMBOLS'],
			['!','@LINE_COMMENT','SYMBOLS'],
			['//','@DS','SYMBOLS'],
			['\n','@EOL','EOL'],
			['\r', '@EOL', 'EOL'],
			['\r\n', '@EOL', 'EOL'],
			['..','@CASE_OP','SYMBOLS', false],
		
			['Αληθής','Αληθής','BOOLEAN'], /* @CTRUE, @CFALSE */
			['Ψευδής','Ψευδής','BOOLEAN'],
		
//			['Α_Μ','@INTVAL','FUNCTIONS'],
//			['Α_Τ','@ABS','FUNCTIONS'],
//			['ΕΦ','@TAN','FUNCTIONS'],
//			['ΗΜ','@SIN','FUNCTIONS'],
//			['ΛΟΓ','@LOG','FUNCTIONS'],
//			['ΣΥΝ','@COS','FUNCTIONS'],
//			['Τ_Ρ','@SQR','FUNCTIONS'],
//			['Ρίζα','@SQR','FUNCTIONS'],
//			['Ε','@Ε','FUNCTIONS'],
//			['Τυχαίος','@RAND','FUNCTIONS']
		];
		public static var wordPattern:RegExp = /[A-Za-zΆ-ώ_0-9]+/;
		public static const LINE_COMMENT:String = '!';
		public static const DECIMAL_SYMBOL:String = '.';
		public static const CTRUE:String = 'Αληθής';
		public static const CFALSE:String = 'Ψευδής';
		public static const ARRAY_LEFT:String = '[';
		public static const ARRAY_RIGHT:String = ']';
		public static const DELIMITER:String = ',';
		public static const EOL:String = '\n';
		public static const PAR_LEFT:String = '(';
		public static const PAR_RIGHT:String = ')';
		public static const ARRAY_MAX_DIM:uint = 3;
		public static var nonWordHash:Array = new Array();
		private static var checkHash:Array = [];
		private static var replaceHash:Object = {'ά' : 'α', 'έ' : 'ε', 'ή' : 'η', 'ί' : 'ι', 'ό' : 'ο', 'ύ' : 'υ', 'ώ' : 'ω', 'ς' : 'σ'};
		Spec.nonWordHash['^'] = ['^'];
		Spec.nonWordHash['+'] = ['+'];
		Spec.nonWordHash['-'] = ['-'];
		Spec.nonWordHash['–'] = ['–'];
		Spec.nonWordHash['*'] = ['*'];
		Spec.nonWordHash['/'] = ['/', '//'];
		Spec.nonWordHash['<='] = ['<='];
		Spec.nonWordHash['<'] = ['<=', '<>', '<', '<-'];
		Spec.nonWordHash['≤'] = ['≤'];
		Spec.nonWordHash['>='] = ['>='];
		Spec.nonWordHash['>'] = ['>=', '>'];
		Spec.nonWordHash['≥'] = ['≥'];
		Spec.nonWordHash['<>'] = ['<>'];
		Spec.nonWordHash['≠'] = ['≠'];
		Spec.nonWordHash['='] = ['='];
		Spec.nonWordHash['..'] = ['..'];
		Spec.nonWordHash['.'] = ['..'];
		Spec.nonWordHash['<-'] = ['<-'];
		Spec.nonWordHash['←'] = ['←'];
		Spec.nonWordHash['⟵'] = ['⟵'];
		Spec.nonWordHash['('] = ['('];
		Spec.nonWordHash[')'] = [')'];
		Spec.nonWordHash['['] = ['['];
		Spec.nonWordHash[']'] = [']'];
		Spec.nonWordHash[','] = [','];
		Spec.nonWordHash['!'] = ['!'];
		Spec.nonWordHash['//'] = ['//'];
		Spec.nonWordHash['\n'] = ['\n'];
		Spec.nonWordHash['\r'] = ['\r'];
		Spec.nonWordHash['\r'] = ['\r', '\r\n'];
		Spec.nonWordHash['\r\n'] = ['\r\n'];
		
		private static var keysHash:Array = new Array();
		private static var valuesHash:Array = new Array();
		{
			Spec.Init();
		}
		internal static function Init():void{
			var entry:Array;
			var k:String, v:String, c :String;
			var iW:Boolean;
			var specKey:SpecKey;			
			for(var i:uint = 0; i < tokens.length; i++) {				
				entry = tokens[i];
				k = entry[0];
				v = entry[1];
				c = entry[2];
				if(entry.length > 3) {
					iW = entry[3];
				}
				else {
					iW = true;
				}				
				specKey = new SpecKey(k, v, c, iW);	
				//needed for correcting case
				var kL:String = k.toLowerCase();			
				keysHash[kL] = specKey;
				valuesHash[v] = specKey;
				checkHash[normaliseGreek(kL)] = specKey;
			}		
		}
		public static function normaliseGreek(s:String):String {
			var r:String = '';
			var c:String;
			for(var i:uint = 0; i < s.length; i++) {
				c = s.charAt(i);
				if(replaceHash.hasOwnProperty(c)) {
					r += replaceHash[c];
				}
				else {
					r += c;
				}
			}
			return r;
		}
		public static function hasNonWord(s:String):Boolean {
			return Spec.nonWordHash.hasOwnProperty(s);
		}
		
		public static function getNonWord(s:String):Array {
			return Spec.nonWordHash[s];
		}
		
		public static function isSymbol(s:String):Boolean {
			return Spec.keysHash.hasOwnProperty(s) && Spec.keysHash[s].category == 'SYMBOLS'; 
		}
		public static function hasKey(s:String, checkPattern:Boolean = false):Boolean {
			if(checkPattern){
				return Spec.checkHash.hasOwnProperty(s);
			}
			else {
				return Spec.keysHash.hasOwnProperty(s);
			}	
		}
		
		public static function getKey(s:String, checkPattern:Boolean = false):SpecKey {
			if(checkPattern){
				return Spec.checkHash[s];	
			}
			else {
				return Spec.keysHash[s];	
			}			
		}
		
		public static function getKeyFromValue(s:String):SpecKey {
			return Spec.valuesHash[s];
		}
		
		public static function isQuote(c:String):Boolean {
			return c == '"' || c == "'";
		}
		
		public static function isWordChar(c:String):Boolean {		
			return wordPattern.test(c);
		}
		public static function isLineComment(s:String):Boolean {
			return s == Spec.LINE_COMMENT;
		}
		public static function isDecimalSymbol(s:String):Boolean {
			return s == Spec.DECIMAL_SYMBOL;
		}
	}
}
