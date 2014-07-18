package pseudoglossa.models
{
	//import pseudoglossa.Obj;
	import mx.utils.ObjectUtil;
	public class Mapper
	{
		public function Mapper(o:Object)
		{			
			map(o);
		}
		public function map(o:Object):void
		{
			var desc:Object = ObjectUtil.getClassInfo(o);
			var name:String;
			//another wasted night
			if(desc.dynamic) {
				for(name in o) {
					if(this.hasOwnProperty(name)) {
						this[name] = o[name];	
					}	
				}
			}
			else {
				var l:uint = desc.properties.length;
				for(var i:uint = 0; i < l; i++) {					
					name = desc.properties[i].localName;
					if(this.hasOwnProperty(name)) {
						this[name] = o[name];
					} 
				}
			}
			
		}
	}
}