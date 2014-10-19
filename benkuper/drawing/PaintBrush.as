package benkuper.drawing 
{
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class PaintBrush extends Sprite 
	{
		
		public var points:Vector.<PaintPoint>;
		protected var _rendering:Boolean;
		
		public function PaintBrush(lineColor:uint = 0xffffff) 
		{
			super();
			points = new Vector.<PaintPoint>();
		}
		
		
		public function addPoint(x:Number,y:Number,color:uint,size:Number,animate:Boolean = true,speed:Point = null):PaintPoint
		{
			if (speed == null) speed = new Point();
			
			var p:PaintPoint = new PaintPoint(x, y, color, size, animate);
			points.push(p);
			
			return p;
		}
		
		public function removePoint(p:PaintPoint):void
		{
			p.destroy(pointDestroyed);
		}
		
		private function pointDestroyed(p:PaintPoint):void 
		{
			points.splice(points.indexOf(p), 1);
		}
		
		
		public function morphFrom(line:PaintBrush,time:Number = 1):void
		{
			rendering = true;
			
			var i:int;
			if (line == null)
			{
				for (i = 0; i < points.length; i++) points[i].morphFrom(null, (i / points.length)*time);
				return;
			}
			
			trace("morph line", line.points.length, "/", points.length);
			
			var p:PaintPoint;
			var curPointIndex:int = 0;
			for each(p in points)
			{
				var delay:Number = (curPointIndex / line.points.length) * time;
				if (curPointIndex < line.points.length) 
				{
					var fromPoint:PaintPoint = line.points[curPointIndex];
					p.morphFrom(fromPoint,delay,2,(curPointIndex >= line.points.length - 2));
				}
				else p.morphFrom(null,delay+1,2);
				curPointIndex++;
			}
			
			for (i = curPointIndex; i < line.points.length; i++)
			{
				p = addPoint(line.points[i].x, line.points[i].y, line.points[i].color, line.points[i].size, false);
				
				removePoint(p);
			}
			
		}
		
		public function finishLine(tail:Boolean):void
		{
			var lastPoint:PaintPoint = points[points.length - 1];
			var lastPoint2:PaintPoint = points[points.length - 2];
			
			points.push(new PaintPoint(lastPoint.x + (lastPoint.x - lastPoint2.x), lastPoint.y + (lastPoint.y - lastPoint2.y), lastPoint.baseColor, lastPoint.baseSize));
			
			if (tail)
			{
				var tailCount:int = Math.min(points.length / 5, 20);
				for (var i:int = 0; i < tailCount; i++)
				{
					var curP:PaintPoint = points[points.length - i -1];
					TweenLite.to(curP, .2, {size:Math.max(curP.size * ((i-1)/tailCount),0) } );
				}
				
				TweenLite.delayedCall(1, disableRendering);
			}
		}
		
		public function clear():void
		{
			graphics.clear();
			points = new Vector.<PaintPoint>();
			rendering = false;
		}
		
		public function disableRendering():void 
		{
			rendering = false;
		}
		
		protected function draw(e:Event = null):void
		{
			//to override
		}
		
		public function drawCircle(tx:Number,ty:Number, radius:Number,color:uint,size:uint):void
		{
			clear();
			rendering = true;
			var numPoints:int = 20;
			for (var i:int = 0; i < numPoints; i++)
			{
				var angle:Number = i * Math.PI * 2 / (numPoints-1);
				addPoint(tx+Math.cos(angle) * radius, ty+Math.sin(angle) * radius, color, size,false);
			}
		}
		
		public function getXML():XML 
		{
			var xml:XML = <line></line>;
			for each(var p:PaintPoint in points) xml.appendChild(p.getXML());
			return xml;
		}
		
		public function loadXML(xml:XML):void 
		{
			var curPoint:int = 0;
			trace("Line load xml !", xml.point.length());
			for each(var pXML:XML in xml.point)
			{
				addPoint(pXML.@x, pXML.@y, pXML.@color, pXML.@size,false);
			}
		}
		
		public function get rendering():Boolean 
		{
			return _rendering;
		}
		
		public function set rendering(value:Boolean):void 
		{
			TweenLite.killDelayedCallsTo(disableRendering)
			
			if (rendering == value) return;
			
			_rendering = value;
			
			if(value)
			{
				
				this.addEventListener(Event.ENTER_FRAME,draw);
			}else
			{
				this.removeEventListener(Event.ENTER_FRAME,draw);
			}
		}
		
		
	}

}