package benkuper.util 
{
	import flash.display.Screen;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class StageUtil 
	{
		static private var stage:Stage;
		
		public function StageUtil() 
		{
			
		}
		
		public static function init(stage:Stage):void
		{
			StageUtil.stage = stage;
			
		}
		
		public static function setNoScale():void
		{
			if (stage == null)
			{
				trace("3: Must StageUtil.init() first !");
				return;
			}
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
		public static function setFromSettings(settingsXML:XML):void
		{
			//todo
		}
		
		public static function setScreen(screenID:int,fullScreen:Boolean = false):void
		{
			if (stage == null)
			{
				trace("3: Must StageUtil.init() first !");
				return;
			}
			
			var targetScreen:Screen = Screen.screens[Math.min(screenID, Screen.screens.length - 1)];
			
			stage.nativeWindow.x = targetScreen.bounds.x;
			stage.nativeWindow.y = targetScreen.bounds.y;
			
			if (fullScreen)
			{
				stage.nativeWindow.width = targetScreen.bounds.width;
				stage.nativeWindow.height = targetScreen.bounds.height;
			}
		}
		
		public static function setScreenRelative(screenID:int,top:Number,left:Number,width:Number,height:Number):void
		{
			if (stage == null)
			{
				trace("3: Must StageUtil.init() first !");
				return;
			}
			
			var targetScreen:Screen = Screen.screens[Math.min(screenID, Screen.screens.length - 1)];
			
			stage.nativeWindow.x = targetScreen.bounds.x+left*targetScreen.bounds.width;
			stage.nativeWindow.y = targetScreen.bounds.y + top * targetScreen.bounds.height;
			stage.nativeWindow.width = width*targetScreen.bounds.width;
			stage.nativeWindow.height = height*targetScreen.bounds.height;
			
			
		}
		
	}

}