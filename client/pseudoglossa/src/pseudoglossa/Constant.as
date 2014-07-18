package pseudoglossa
{
	public class Constant extends Expression 
	{
		public var _value:*;
		
		public function Constant(value:*, type:String)
		{
			if(type == 'STRING') {
				_value = value.substring(1, value.length - 1);
			} else if (type == 'BOOLEAN') {
				_value = value == Spec.CTRUE ? true : false;
			} else if(type == 'NUMBER') {
				_value = Number(value);
			}  else {
				_value = value;
			}
			this.type = type;
		}
		
		override public function get value():*
		{
			return _value;
		}
	}
}