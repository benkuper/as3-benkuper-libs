package benkuper.util 
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class KeyboardUtil 
	{
		static private var stage:Stage;
		
		private static var _ctrlPressed:Boolean;
		private static var _shiftPressed:Boolean;
		private static var _altPressed:Boolean;
		
		public function KeyboardUtil() 
		{
			
		}
		
		public static function init(stage:Stage):void
		{
			stage = stage;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
		}
		
		
		
		static private function keyHandler(e:KeyboardEvent):void 
		{
			_shiftPressed = e.shiftKey;
			_altPressed = e.altKey;
			_ctrlPressed = e.ctrlKey;
		}
		
		static public function get ctrlPressed():Boolean 
		{
			return _ctrlPressed;
		}
		
		static public function get shiftPressed():Boolean 
		{
			return _shiftPressed;
		}
		
		static public function get altPressed():Boolean 
		{
			return _altPressed;
		}
	}

}