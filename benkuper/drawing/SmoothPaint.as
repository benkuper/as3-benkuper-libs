package benkuper.drawing 
{
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class SmoothPaint extends Sprite 
	{
		public var lines:Vector.<PaintBrush>;
		public var currentLine:PaintBrush;
		
		private var pointer:Point;
		private var drawing:Boolean;
		
		private var canvasWidth:Number;
		private var canvasHeight:Number;
		
		public var lineWidth:Number;
		public var lineColor:uint;
		public var lastPress:Number;
		public var curSpeed:Point;
		public var prevPointer:Point;
		public var startPoint:Point;
		
		private var _enabled:Boolean;
		
		public var id:String = "paint";
		
		public var brush:Class = PaintLine;
		
		public function SmoothPaint(width:Number = 200,height:Number = 200) 
		{
			super();
			this.canvasHeight = height;
			this.canvasWidth = width;
			
			drawBG();
			
			this.lines = new Vector.<PaintBrush>();
			
			pointer = new Point();
			prevPointer = new Point();
			lineWidth = 3;
			lineColor = 0xffffff;
			
			curSpeed = new Point();
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function drawBG():void 
		{
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, canvasWidth, canvasHeight);
			graphics.endFill();
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			enabled = true;
		}
		
		
		private function mouseHandler(e:MouseEvent):void 
		{
			
			switch(e.type)
			{
				case MouseEvent.MOUSE_DOWN:
					
					
					TweenLite.killTweensOf(pointer);
					TweenLite.killTweensOf(curSpeed);
					
					//brush = (brush == PaintLine?PaintCircles:PaintLine);
					pointer.x = mouseX;
					pointer.y = mouseY;
					
					curSpeed = new Point();
					
					prevPointer = pointer.clone();
					startPoint = pointer.clone();
					curSpeed = new Point();
					
					addLine();
					
					lastPress = getTimer();
					
					stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
					stage.addEventListener(Event.ENTER_FRAME, mouseEnterFrameHandler);
					
					drawing = true;
					
					
					//graphics.beginFill(0xff0000);
					//graphics.drawCircle(pointer.x, pointer.y,10)
					//graphics.endFill();
					break;
					
				case MouseEvent.MOUSE_UP:
					if (stage != null)
					{
						stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);
						stage.removeEventListener(Event.ENTER_FRAME, mouseEnterFrameHandler);
					}
					
					drawing = false;
					
					if (getTimer() -lastPress < 100 && Point.distance(startPoint,new Point(mouseX,mouseY)) < 20)
					{
						currentLine.drawCircle(mouseX,mouseY, 10, lineColor, lineWidth);
						currentLine.finishLine(false);
					}else
					{
						currentLine.finishLine(true);
					}
					
					break;
			}
		}
		
		
		private function mouseEnterFrameHandler(e:Event):void 
		{
			//pointer.x = mouseX;
			//pointer.y = mouseY;
			TweenLite.to(pointer, .4, { x:mouseX, y:mouseY } );
			//
			TweenLite.to(curSpeed, .1, {x:pointer.x-prevPointer.x,y:pointer.y-prevPointer.y} );
			
			prevPointer.x = pointer.x;
			prevPointer.y = pointer.y;
			
		}
		
		
		
		private function drawEnterFrame(e:Event):void 
		{
			if (!drawing) return;
			//graphics.beginFill(0xffff00),
			//graphics.drawCircle(pointer.x, pointer.y,2);
			//graphics.endFill();
			currentLine.addPoint(pointer.x, pointer.y,lineColor,Math.abs(lineWidth+curSpeed.length/10),false,curSpeed);
		}
		
		public function addLine(line:PaintBrush = null):void
		{
			//if (currentLine != null) this.currentLine.rendering = false;
			if (line == null) line = new brush(lineColor);
			
			currentLine = line;
			currentLine.rendering = true;
			lines.push(currentLine);
			addChild(currentLine);
		}
		
		public function removeLine(l:PaintBrush):void 
		{
			l.clear();
			lines.splice(lines.indexOf(l), 1);
			trace("remove line, new num lines :",lines.length);
		}
		
		public function clear():void
		{
			for each(var l:PaintBrush in lines) l.clear();
			
			lines = new Vector.<PaintBrush>();
			currentLine = null;
		}
		
		public function morphFrom(paint:SmoothPaint):void 
		{
			if (paint == null) return;
			var curLineIndex:int = 0;
			
			trace("Paint morph prev lines :", paint.lines.length + ", cur lines :", lines.length);
			for each(var l:PaintBrush in lines)
			{
				if (curLineIndex < paint.lines.length) 
				{
					l.morphFrom(paint.lines[curLineIndex]);
				}else 
				{
					l.morphFrom(null);
					
				}
				curLineIndex++;
			}
			
			for (var i:int = curLineIndex; i < paint.lines.length; i++)
			{
				trace("add Line");
				addLine();
				trace(currentLine.points.length + "/" + paint.lines[i].points.length);
				currentLine.morphFrom(paint.lines[i]);
				//removeLine(currentLine);
				TweenLite.delayedCall(1, removeLine, [currentLine]);
			}
			
		}
		
		public function getXML():XML
		{
			var xml:XML = <paint></paint>;
			for each(var l:PaintBrush in lines) xml.appendChild(l.getXML());
			return xml;
		}
		
		public function save():File 
		{
			var f:File = File.documentsDirectory.resolvePath(File.applicationDirectory.resolvePath("paints/" + this.id+".xml").nativePath);
			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.WRITE);
			fs.writeUTFBytes(getXML().toXMLString());
			fs.close();
			
			return f;
		}
		
		public function load():void 
		{
			var f:File = File.documentsDirectory.resolvePath(File.applicationDirectory.resolvePath("paints/" + this.id + ".xml").nativePath);
			if (!f.exists) return;
			
			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.READ);
			var xml:XML = new XML(fs.readUTFBytes(fs.bytesAvailable));
			fs.close();
			
			loadXML(xml);
		}
		
		private function loadXML(xml:XML):void 
		{
			clear();
			for each(var lXML:XML in xml.line)
			{
				
				addLine();
				currentLine.loadXML(lXML);
			}
		}
		
		public function get enabled():Boolean 
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void 
		{
			if (enabled == value) return;
			_enabled = value;
			if (value)
			{
				addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
				addEventListener(Event.ENTER_FRAME, drawEnterFrame);
			}else
			{
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
				removeEventListener(Event.ENTER_FRAME, drawEnterFrame);
			}
			
		}
		
		
		
	}

}