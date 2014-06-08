package benkuper.util
{
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class Shortcutter extends EventDispatcher 
	{
		
		public static var instance:Shortcutter;
		private static var stage:Stage;
		
		private static var targets:Vector.<Object>;
		
		public static var shiftKey:Boolean;
		public static var controlKey:Boolean;
		
		public function Shortcutter() 
		{
		}
		
		public static function init(_stage:Stage):void
		{
			stage = _stage;
			targets = new Vector.<Object>();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
			
			new Shortcutter();
			
		}
		
		public static function add(target:Object):void
		{
			if (target == null)
			{
				trace("4:Shortcut::addShortcuts, target is null !");
				return;
			}
			
			if (targets.indexOf(target) != -1)
			{
				trace("4:target already added !");
				return;
			}
			
			targets.push(target);
		}
		
		public static function remove(target:Object):void
		{
			targets.splice(targets.indexOf(target), 1);
		}
		
		private static function keyHandler(e:KeyboardEvent):void 
		{			
			
			shiftKey = e.shiftKey;
			controlKey = e.controlKey;
			
			
			for each(var target:Object in targets)
			{
				var char:String = String.fromCharCode(e.charCode);
				var mds:XMLList = describeType(target)..metadata.(@name == "Shortcut");
				//trace(describeType(target));
				var keyArg:XMLList = mds.arg.(attribute("value") == char);
				
				if (keyArg.length() == 0)
				{
					continue;
				}
				
				var md:XML = keyArg.parent();
				var item:XML = md.parent();	
				
				var itemType:String = item.name();
				var prop:String = item.@name;
				
				if (md.arg.(@key == "keyMask").@value == "shift" &&  !shiftKey) return;
				if (md.arg.(@key == "keyMask").@value == "control" &&  !controlKey) return;
				
				switch(itemType)
				{
					
					case "accessor":
						//trace("accessor !");
						
					case "variable":
						processVariable(target,item, md, prop,e.type);
						
						break;
						
					case "method":
						processMethod(target,item, md, prop,e.type);
						
						break;
				}
			}
		}
		
		static private function processMethod(target:Object, item:XML, md:XML, prop:String, eventType:String):void 
		{
			if (eventType != KeyboardEvent.KEY_DOWN) return;
			
			
			
			var hasParams:Boolean;
			var params:Array = new Array();
			
			
			if ("@key" in md.arg)
			{
				if (md.arg.(@key == "params").length() > 0)
				{
					hasParams = true;
					params = md.arg.(@key == "params").@value.toString().split(",");
				}else
				{
					hasParams = false;
				}
				
				
			}
			
			trace("0:[Shortcutter :: Launch method "+prop+", hasParams = "+hasParams+", params = "+params.join(",")+"]");
			
			if (hasParams && params.length > 0)
			{
				target[prop](params);
				
			}else
			{
				target[prop]();
			}
		}
		
		static private function processVariable(target:Object, item:XML, md:XML, prop:String, eventType:String):void 
		{
			var ItemClass:Class = getDefinitionByName(item.@type) as Class;
			
			var type:String = md.arg.(attribute("key") == "type").@value;
				
			if (type != "bang" && eventType != KeyboardEvent.KEY_DOWN) return;
			
			
			var value:Object ;
			
			if (type == "")
			{
				switch(ItemClass)
				{
					case Boolean:
						type = "toggle";
						break;
					
					case int:
						type = "add";
						break;
						
					case String:
						type = "set";
						break;
					
					case Number:
						type = "add";
						break;
				}
			}
				
			switch(type)
			{
				case "add":
					value = Number(md.arg.(@key == "value").@value);					
					if (value == "" || value == null) value = 1;
					target[prop] += Number(value);
					break;
					
				case "subtract":
					value = Number(md.arg.(@key == "value").@value);
					if (value == "" || value == null) value = 1;
					target[prop] -= Number(value);
					break;
					
				case "bang":
					target[prop] = eventType == KeyboardEvent.KEY_DOWN;
					break
					
				case "toggle":
					target[prop] = !(target[prop] as Boolean);
					break
					
				case "set":
					value = md.arg.(@key == "value").@value;
					if (value == "" || value == null) trace("3:no value set for "+prop);
					target[prop] = value;
					break;
					
			}
			
			trace("0:New value for " + target + "[" + prop + "] :", target[prop]);
		}
		
		
	}

}