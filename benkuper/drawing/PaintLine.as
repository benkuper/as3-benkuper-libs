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
	public class PaintLine extends PaintBrush 
	{
		
		public function PaintLine(lineColor:uint = 0xffffff) 
		{
			super(lineColor);
			points = new Vector.<PaintPoint>();
			
			filters = [new DropShadowFilter(2, 45, 0, 1, 20,20,1.5)];
		}
		
		
		override protected function draw(e:Event = null):void
		{
			if (points.length < 2) {
				return;
			}
			
			var numPoints:int = points.length;
			var prevP:PaintPoint;
			var curP:PaintPoint;
			var nextP:PaintPoint;
			
			var lastAngle:Number = 0;
			
			graphics.clear();
			
			for (var i:int = 1; i < numPoints;i++)
			{
				prevP = points[i - 1];
				curP = points[i];
				if (i < numPoints - 1) 
				{
					nextP = points[i + 1];
				}else
				{
					nextP = null;
				}
				
				if (curP == null) continue;
				if (prevP == null) continue;
				if (nextP == null) continue;
				
				var midPrevPoint:Point = Point.interpolate(prevP.position, curP.position, .5);
				var midNextPoint:Point = Point.interpolate(curP.position, nextP.position, .5);
				
				var angle:Number;
				
				if (nextP != null)
				{
					//angle = -Math.atan2(prevP.x - nextP.x, prevP.y - nextP.y) - Math.PI / 2 ; //prev to next angle //use for straight lines
					angle = -Math.atan2(curP.x - nextP.x, curP.y - nextP.y) - Math.PI / 2 ; //cur to next angle //use for curves
				}else
				{
					angle = -Math.atan2(prevP.x - curP.x, prevP.y - curP.y) - Math.PI / 2 ; //prev to cur angle
				}
				
				var rot:Number =  angle * 180 / Math.PI;
				
				var perpAngle:Number = angle + Math.PI/2;
				var perpRot:Number = perpAngle * 180 / Math.PI;
				
				
				var prevCurAngle:Number = -Math.atan2(prevP.x - curP.x, prevP.y - curP.y); 
				var nextCurAngle:Number = -Math.atan2(curP.x - nextP.x, curP.y - nextP.y); 
				var midPrevSize:Number = (prevP.size + curP.size) / 2;
				var midNextSize:Number = (curP.size + nextP.size) / 2;
				
				var p1x1:Number = midPrevPoint.x - Math.cos(prevCurAngle) * midPrevSize;
				var p1y1:Number = midPrevPoint.y - Math.sin(prevCurAngle) * midPrevSize;
				var p1x2:Number = midPrevPoint.x + Math.cos(prevCurAngle) * midPrevSize;
				var p1y2:Number = midPrevPoint.y + Math.sin(prevCurAngle) * midPrevSize;
				
				var pcx1:Number = curP.x - Math.cos(perpAngle) * curP.size;
				var pcy1:Number = curP.y - Math.sin(perpAngle) * curP.size;
				var pcx2:Number = curP.x + Math.cos(perpAngle) * curP.size;
				var pcy2:Number = curP.y + Math.sin(perpAngle) * curP.size;
				
				var p2x1:Number = midNextPoint.x - Math.cos(nextCurAngle) * midNextSize;
				var p2y1:Number = midNextPoint.y - Math.sin(nextCurAngle) * midNextSize;
				var p2x2:Number = midNextPoint.x + Math.cos(nextCurAngle) * midNextSize;
				var p2y2:Number = midNextPoint.y + Math.sin(nextCurAngle) * midNextSize;
				
				if(!curP.lineMode) graphics.beginFill(curP.color);
				
				if (curP.lineMode) graphics.lineStyle(2,curP.color);//,curP.color);
				
				graphics.moveTo(p1x1,p1y1);
				
				graphics.curveTo(pcx1,pcy1 , p2x1, p2y1 );
				
				graphics.lineTo(p2x2,p2y2);
				
				graphics.curveTo(pcx2,pcy2,p1x2,p1y2);
				
				graphics.lineTo(p1x1,p1y1);
				
				if(!curP.lineMode) graphics.endFill();
				
				lastAngle = perpAngle;
			}
		}		
	}
	
	

}