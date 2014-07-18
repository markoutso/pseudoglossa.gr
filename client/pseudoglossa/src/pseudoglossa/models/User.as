package pseudoglossa.models 
{
	[Bindable]
    //[RemoteClass(alias="Default_Model_Amf_User")]
	public class User extends Mapper
	{
		public var id:uint;
		public var username:String;
		public var password:String;
		public var email:String;
		public var firstName:String;
		public var lastName:String;
		public var dateRegistered:String;
		public var settings:Object;
		
		public function User(o:Object)
		{
			super(o);
		}
		
		public function toString():String
		{
			return 'username : ' + username;
		}		
	}
}