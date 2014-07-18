
//http://rmirabelle.typepad.com/flash/2009/05/object-debugging-class.html
package pseudoglossa {
    /**
* object utilities
*/
    import flash.display.MovieClip;
    import flash.utils.*;
 
    public class Obj {
 
        /**
* AS3 has a remarkable weakness that prevents you
* from being able to use a for...in or for each...in
* loop to traverse the properties of an instance.
* Documentation states that only dynamic properties
* can be looped through, which seems to imply that if
* you make your class dynamic, you'll have access to
* its properties - NOT SO. If you make your class dynamic
* you still only have access to the properties that you
* dynamically (manually) SET at runtime. For example:
*
* public dynamic class MyClass {
* public var my_var:String = 'cool';
* }
* var my_instance:MyClass = new MyClass();
* my_instance.some_new_var = 'huh?';
*
* for(var x in my_instance) {
* trace(x + ':' + my_instance[x]);
* }
* outputs:
* some_new_var:huh
* and completely skips over the expected:
* my_var:cool
*
* This method overcomes that limitation by inspecting
* a given class using reflection and copying a snapshot of
* the public properties and their values over to a new Object.
* Each new property assigned to the new Object is
* inherently dynamically SET and so we can loop
* through the copy as we would the original object
*
* @example
* var snap:Object = Obj.snapshot(my_instance);
* for(var x in snap) {
* trace(x + ':' + snap[x]);
* }
* outputs:
* some_new_var:huh
* my_var:cool
*
*/
        public static function snapshot(o:Object):Object {
 
            var state:Object = new Object();
 
            /**
* first get all the dynamically set properties
*/
            var num_dynamic_found:Number = 0;
            for(var x in o) {
                state[x] = o[x];
                num_dynamic_found++;
            }
 
            /**
* then get all the instance properties
*/
            var def:XML = describeType(o);
            var props:XMLList = def..variable.@name;
 
            /**
* if no dynamic properties are found then
* dig deeper into the object by getting
* its intrinsic properties including getters
* and setters - do this only for non-MovieClip
* objects
*/
            if(num_dynamic_found == 0 && !o is MovieClip) {
                props += def..accessor.@name;
            }
            for each(var prop in props) {
                var val:* = o[prop];
                var object_val:Object = snapshot(val);
                for(var q in object_val) {
                    state[prop + ':' + q] = object_val[q];
                }
                state[prop] = val;
            }
            return state;
        }
 
        public static function get_type(o:*):String {
            var xml:XML = describeType(o);
            return xml.@name;
        }
 
        public static function to_xml(o:*):String {
            var def:XML = describeType(o);
            return def.toXMLString();
        }
 
        /**
* debugs an object and returns the string rather
* than tracing it
*/
        public static function to_string(o:Object):String {
            var out:String = '';
            var obj:Object = snapshot(o);
            for(var x in obj) {
                if(out != '') out += ', ';
                out += x + '=' + obj[x];
            }
            return out;
        }
		
        /**
* debugs an object by taking a snapshot of
* its state and tracing an alphabetized list
* of properties and their values
*/
        public static function debug(o:Object):void {
            var obj:Object = snapshot(o);
            var arr:Array = new Array();
            for(var x in obj) {
                arr.push([x, obj[x]]);
            }
            arr.sort();
            for(var y in arr) {
                trace(arr[y][0] + ':' + arr[y][1]);
            }
        }
    }
}

