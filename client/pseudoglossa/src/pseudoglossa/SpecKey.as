package pseudoglossa
{
	
	public class SpecKey
	{
		public var key:String;
		public var value:String;
		public var category:String;
		public var isWord:Boolean;
		
		public function SpecKey(key:String, value:String, category:String, isWord:Boolean)
		{
			this.key = key;
			this.value = value;
			this.category = category;
			this.isWord = isWord;
		}
	}
}