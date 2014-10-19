package benkuper.drawing 


{
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class PaintCircles extends PaintBrush 
	{
		
		public function PaintCircles(lineColor:uint = 0xffffff) 
		{
			super(lineColor);
			filters = [new GlowFilter(lineColor, 1, 10,10, 1, 2)];
		}
		
		
		override public function addPoint(x:Number,y:Number,color:uint,size:Number,animate:Boolean = true,speed:Point = null):PaintPoint
		{
			if (speed == null) speed = new Point();
			
			var p:PaintPoint = new PaintPoint(x, y, color, size, false);
				
			TweenLite.to(p, .2 + Math.random() * 2, { x:p.x + (Math.random() * 2 - 1) *3+speed.x*2, y:p.y + (Math.random() * 2 - 1) *3+speed.y*2,ease:Strong.easeOut } );
			
			//var p:PaintPoint = new PaintPoint(x, y, color, size, animate);
			points.push(p);
			
			return p;
		}
		
		
		override protected function draw(e:Event = null):void
		{
			graphics.clear();
			
			var steps:int = 2;
			
			var numPoints:int = points.length;
			for (var i:int = 0; i < numPoints;i++ )
			{
				var p:PaintPoint = points[i];
				p.update();
				//graphics.lineStyle(p.size, p.color);
				//graphics.drawCircle(p.x, p.y,p.size);
				//graphics.moveTo(p.x - p.speed.x, p.y - p.speed.y);
				//graphics.lineTo(p.x + p.speed.x, p.y + p.speed.y + 1);
				
				
				if (i < numPoints - steps)
				{
					graphics.lineStyle(p.size / 2, p.color, .6);
					
					for (var j:int = 1; j <= steps; j++)
					{
						var np:PaintPoint = points[i + j];
						
						graphics.moveTo(p.x+p.speed.x, p.y+p.speed.y);
						graphics.lineTo(np.x - np.speed.x, np.y - np.speed.y);
					}
				}
				graphics.endFill();
				
			}
			
		}
	}
	
	

}