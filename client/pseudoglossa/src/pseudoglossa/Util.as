package pseudoglossa 
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.DescribeTypeCache;
	
	public class Util 
	{
		
		public static function clone(source:Object,depth:int=0):Object {
			var className:String = getQualifiedClassName(source);
			if (isBasicType(className)) {
				throw new Error("can’t clone basic types");
			}
			else if (className == "Array") 	{
				return cloneArray(source as Array,depth);
			}
			else {
				return cloneObject(source,depth);
			}
		}
		/*
		* true if a basic type (int,Number,Boolean)
		* Array and Date are not basic types
		*/
		private static function isBasicType(className:String):Boolean
		{
			return (className.indexOf(":")==-1 && className!="Array" && className!="Date");
		}
		/*
		* clone a complex type
		*/
		private static function cloneObject(source:Object,depth:int=0):Object {
			var clone:Object;
			if (source) {
				clone = newObject(source);
				if(clone) {
					copyProperties(source, clone,depth);
				}
			}
			return clone;
		}
		/*
		* create dynamically a new object
		*/
		private static function newObject(sourceObj:Object):* {
			if(sourceObj) {
				try {
					var className:String = getQualifiedClassName(sourceObj);
					var classOfSourceObj:Class = getDefinitionByName(className) as Class;
					var sourceInfo:XML = DescribeTypeCache.describeType(sourceObj).typeDescription;
					var l:uint = sourceInfo.child("constructor").children().length();
					if(l == 0) { 
						return new classOfSourceObj();
					} else if(l == 1) {
						return new classOfSourceObj(null);
					} else if(l == 2) {
						return new classOfSourceObj(null, null);
					} else if(l == 3) {
						return new classOfSourceObj(null, null, null);
					} else if(l == 4) {
						return new classOfSourceObj(null, null, null, null);
					} else if(l == 5) {
						return new classOfSourceObj(null, null, null, null, null);
					} else {
						throw Error('cannot copy object');
					}
					
				}
				catch(e:Error)
				{
					trace(e.toString());
				}
			}
			return null;
		}
		/*
		* used to log recursion
		*/
		private static function debugPrefix(depth:int):String
		{
			var prefix:String = "";
			for (var j:int=0;j<depth;j++)
			{
				prefix += " ";
			}
			return prefix;
		}
		/*
		* clone each array's items regarding their types
		*/
		private static function cloneArray(arraySrc:Array,depth:int=0):Array {
			var prefix:String = debugPrefix(depth);
			var arrayDst:Array = new Array();
			for (var i:int=0;i<arraySrc.length;i++)
			{
				var elementType:String = getQualifiedClassName(arraySrc[i]);
				//trace(prefix+" array["+i+"]:"+elementType);
				if (isBasicType(elementType))
				{
					arrayDst.push(arraySrc[i]);
				}
				else if(elementType=="Array")
				{
					arrayDst.push(cloneArray(arraySrc[i],depth+1));
				}
				else
				{
					arrayDst.push(clone(arraySrc[i],depth+1));
				}
			}
			return arrayDst;
		}
		/*
		* clone each object properties regarding their types
		*/
		private static function copyProperties(source:Object, destination:Object,depth:int=0):void {
			var propType:String = "";
			var prefix:String = debugPrefix(depth);
			var arraySrc:Array;
			if((source) && (destination)) {
				try {
					var sourceInfo:XML = DescribeTypeCache.describeType(source).typeDescription;
					var prop:XML;
					//trace(prefix+"Clone "+sourceInfo.@name);
					
					for each(prop in sourceInfo.variable) {	
						propType = prop.@type;
						if (isBasicType(propType)) {
							destination[prop.@name] = source[prop.@name];
						}
						else if( propType=="Array") {
							arraySrc = source[prop.@name] as Array;
							destination[prop.@name] = cloneArray(arraySrc,depth+1);
						}
						else {
							destination[prop.@name] = clone(source[prop.@name],depth+1);
						}					
					}
//					for each(prop in sourceInfo) {
//						propType = prop.@type;
//						if(prop.@access == "readwrite") {
//							if(destination.hasOwnProperty(prop.@name)) {
//								//trace(prefix+" property "+prop.@name+":"+propType);
//								if (isBasicType(propType)) {
//									destination[prop.@name] = source[prop.@name];
//								}
//								else if( propType=="Array") {
//									arraySrc = source[prop.@name] as Array;
//									destination[prop.@name] = cloneArray(arraySrc,depth+1);
//								}
//								else {
//									destination[prop.@name] = clone(source[prop.@name],depth+1);
//								}
//							}
//						}
//					}
				}
				catch (err:Error) {
					trace(err.toString());
				}
			}
		}
	}
}