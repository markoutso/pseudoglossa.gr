package pseudoglossa.components
{
	import mx.validators.StringValidator;
	import mx.validators.ValidationResult;

	public class PasswordValidator extends StringValidator
	{
		private var _confirmPass:Object;
		private var _matchError:String = 'Τα συνθηματικά δεν ταιριάζουν';
		
		public function set confirmPass(value:Object):void
		{
			_confirmPass = String(value);
		}
		public function get confirmPass():Object
		{
			return _confirmPass;
		}
		public function PasswordValidator()
		{
			super();
		}
		
		public function set matchError(value:String):void 
		{
			_matchError = value;
		}
		
		[Inspectable(category="Errors", defaultValue="null")]
		public function get matchError():String 
		{
			return _matchError;
		}
		
		
		public static function validateString(validator:PasswordValidator,
											  value:Object,
											  baseField:String = null):Array
		{
			
			var results:Array = StringValidator.validateString(validator, value, baseField);
			var confirmPass:String = String(validator.confirmPass);
			
			var val:String = value != null ? String(value) : "";
			
			
			
			if (val != confirmPass)
			{
				results.push(new ValidationResult(
				true, baseField, "matchError", 'Τα συνθηματικά δεν ταιριάζουν'));
			}
			
			return results;
		}
		
		override protected function doValidation(value:Object):Array
		{
			var results:Array = super.doValidation(value);
			
			// Return if there are errors
			// or if the required property is set to false and length is 0.
			var val:String = value ? String(value) : "";
			if (results.length > 0 || ((val.length == 0) && !required))
			return results;
			else
			return PasswordValidator.validateString(this, value, null);
		}
		
	}
}