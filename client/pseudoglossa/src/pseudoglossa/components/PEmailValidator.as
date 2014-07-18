package pseudoglossa.components
{
	import mx.validators.EmailValidator;
	
	public class PEmailValidator extends mx.validators.EmailValidator
	{
		public function PEmailValidator()
		{
			super();
			invalidCharError = 'μη έγκυρη διεύθυνση email';
			invalidDomainError = 'μη έγκυρη διεύθυνση email';
			invalidIPDomainError = 'μη έγκυρη διεύθυνση email';
			invalidPeriodsInDomainError = 'μη έγκυρη διεύθυνση email';
			missingAtSignError = 'μη έγκυρη διεύθυνση email';
			missingPeriodInDomainError = 'μη έγκυρη διεύθυνση email';
			missingUsernameError = 'μη έγκυρη διεύθυνση email';
			requiredFieldError = 'υποχρεωτικό πεδίο';
		}

	}
}