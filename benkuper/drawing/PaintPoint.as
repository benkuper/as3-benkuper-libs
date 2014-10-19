package benkuper.drawing 
{
	import com.greensock.easing.Back;
	import com.greensock.easing.Ease;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class PaintPoint extends EventDispatcher
	{
		
		public var basePosition:Point;
		public var position:Point;
		public var lastPosition:Point;
		
		public var speed:Point;
		
		public var baseSize:Number;
		public var size:Number;
		
		
		public var baseColor:uint;
		public var color:uint;
		
		public var lineMode:Boolean;
		
		public function PaintPoint(x:Number,y:Number,color:uint,size:Number,animate:Boolean = true) 
		{
			super();
			basePosition = new Point(x, y);
			position = new Point(x, y);
			lastPosition = new Point(x, y);
			
			speed = new Point();
			
			this.size = size;
			this.baseSize = size;
			
			this.baseColor = color;
			this.color = color;
			
			if (animate) 
			{
				lineMode = true;
				TweenMax.from(this, .2, {size:size+20,hexColors:{color:0x52B1F8},ease:Strong.easeOut,onComplete:finishStart} );
			}
			
			
		}
		
		public function update():void
		{
			speed.x = position.x - lastPosition.x;
			speed.y = position.y - lastPosition.y;
			lastPosition.x = position.x;
			lastPosition.y = position.y;
		}
		
		private function finishStart():void 
		{
			lineMode = false;
		}
		
		public function morphFrom(p:PaintPoint,delay:Number = 0,time:Number=1,zeroSize:Boolean = false, ease:Ease = null):void
		{
			
			//if(p !=null )trace("point morph from :", p.x, p.y, "[origin:", x, y + "]");
			if (ease == null) ease = Strong.easeInOut;
			
			if (p != null) 
			{
				x = p.x;
				y = p.y;
				color = p.color;
				size = zeroSize?0:p.size;
				TweenMax.to(this, time,	{ delay:delay,x:basePosition.x,y:basePosition.y,hexColors:{color:baseColor},size:baseSize,ease:ease});
			}else 
			{
				size = 0;
				TweenMax.to(this, time, {delay:delay, size:baseSize} );
			}
		}
		
		public function destroy(callback:Function = null):void 
		{			
			TweenMax.to(this, .3, { size:0,onComplete:callback,onCompleteParams:[this] } );
		}
		
		
		public function getXML():XML 
		{
			var xml:XML = <point></point>;
			xml.@x = basePosition.x;
			xml.@y = basePosition.y;
			xml.@size = baseSize;
			xml.@color = color;
			return xml;
		}
		
		public function get x():Number
		{
			return position.x;
		}
		
		public function set x(value:Number):void
		{
			position.x = value;
		}
		
		public function get y():Number
		{
			return position.y;
		}
		
		public function set y(value:Number):void
		{
			position.y = value;
		}
		
	}

}