package pseudoglossa
{
	import mx.collections.ArrayCollection;

	public class SymbolTable
	{
		public var h:Object;
		public var collection:ArrayCollection;
		private var colIndexes:Object;
		
		public function SymbolTable()
		{
			this.h = {};
			this.collection = new ArrayCollection();
			this.colIndexes = {};
		}
		
		public function get(key:String):Object
		{
			if(h.hasOwnProperty(key)) {
				return h[key];
			} else {
				return null;
			}
		}
		
		public function has(key:String):Boolean
		{
			return h.hasOwnProperty(key);
		}
		
		public function del(key:String):void
		{
			delete h[key];
		}
		
		public function set(key:String, o:*):Object
		{
			h[key] = o;
			//FIXME: remove watch window logic
			updateCollection(key, o);
			return o;
		}
		
		public function updateCollection(key:String, o:*):void
		{
			if(o is Boolean) {
				// wtf? ο = o ? 'Αληθής' : 'Ψευδής';
				if(o) {
					o = 'Αληθής';
				} else {
					o = 'Ψευδής'; 
				}
			}
			var entry:Object = {name: key, value: o};
			var arrkey:String;
			if (key.indexOf('$') < 0) {
				if(typeof o == 'object') {
					updateArrayInCollection(key, o);
				} else {
					if(!colIndexes.hasOwnProperty(key)) {
						colIndexes[key] = entry;
						collection.addItem(entry);
					} else {
						collection.setItemAt(entry, collection.getItemIndex(colIndexes[key]));
						colIndexes[key] = entry;
					}
				}
			}
		}	
		public function updateArrayInCollection(name:String, o:Object):void
		{
			var arrkey:String;
			for(var k:String in o) {
				arrkey = '  ' + name + k;
				updateCollection(arrkey, o[k]);
			}
		}
	}		
}