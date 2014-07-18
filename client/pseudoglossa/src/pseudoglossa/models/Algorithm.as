package pseudoglossa.models 
{
	[Bindable]
    //[RemoteClass(alias="Default_Model_Amf_Algorithm")]
	public class Algorithm extends Mapper
	{
		public var id:uint;
		public var created:String;
		public var updated:String;
		public var userId:uint;
		public var name:String;
		public var body:String;
		public var notes:String;
		public var userTags:Array;
		public var globalTags:Array;
		public var inputFile:String;
		
		public function Algorithm(o:Object = null)
		{
			name = 'Νέος αλγόριθμος';
			if(o) {
				super(o);	
			}
			
		}
		
		public function toString():String
		{
			return 'name : ' + name;
		}		
	}
}