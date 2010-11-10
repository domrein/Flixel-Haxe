package org.flixel.data;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import org.flixel.FlxG;
	import org.flixel.FlxMonitor;
	
	#if flash9
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	#end

	/**
	 * Contains all the logic for the developer console.
	 * This class is automatically created by FlxGame.
	 */
	class FlxConsole extends Sprite {
		
		public var mtrUpdate:FlxMonitor;
		public var mtrRender:FlxMonitor;
		public var mtrTotal:FlxMonitor;
		
		/**
		 * @private
		 */
		var MAX_CONSOLE_LINES:Int ;
		/**
		 * @private
		 */
		var _console:Sprite;
		/**
		 * @private
		 */
		var _text:TextField;
		/**
		 * @private
		 */
		var _fpsDisplay:TextField;
		/**
		 * @private
		 */
		var _extraDisplay:TextField;
		/**
		 * @private
		 */
		var _curFPS:Int;
		/**
		 * @private
		 */
		var _lines:Array<String>;
		/**
		 * @private
		 */
		var _Y:Float;
		/**
		 * @private
		 */
		var _YT:Float;
		/**
		 * @private
		 */
		var _bx:Int;
		/**
		 * @private
		 */
		var _by:Int;
		/**
		 * @private
		 */
		var _byt:Int;
		
		/**
		 * Constructor
		 * 
		 * @param	X		X position of the console
		 * @param	Y		Y position of the console
		 * @param	Zoom	The game's zoom level
		 */
		public function new(X:Int,Y:Int,Zoom:Int)
		{
			
			MAX_CONSOLE_LINES = 256;
			super();
			
			visible = false;
			x = X*Zoom;
			_by = Y*Zoom;
			_byt = _by - FlxG.height*Zoom;
			_YT = _Y = y = _byt;
			var tmp:Bitmap = new Bitmap(new BitmapData(FlxG.width*Zoom,FlxG.height*Zoom,true,0x7F000000));
			addChild(tmp);
			
			mtrUpdate = new FlxMonitor(8);
			mtrRender = new FlxMonitor(8);
			mtrTotal = new FlxMonitor(8);

			_text = new TextField();
			_text.width = tmp.width;
			_text.height = tmp.height;
			_text.multiline = true;
			_text.wordWrap = true;
			_text.selectable = false;
			#if flash9
			_text.embedFonts = true;
			_text.antiAliasType = AntiAliasType.NORMAL;
			_text.gridFitType = GridFitType.PIXEL;
			#else
			#end
			_text.defaultTextFormat = new TextFormat("system",8,0xffffff);
			addChild(_text);

			_fpsDisplay = new TextField();
			_fpsDisplay.width = 100;
			_fpsDisplay.x = tmp.width-100;
			_fpsDisplay.height = 20;
			_fpsDisplay.multiline = true;
			_fpsDisplay.wordWrap = true;
			_fpsDisplay.selectable = false;
			#if flash9
			_fpsDisplay.embedFonts = true;
			_fpsDisplay.antiAliasType = AntiAliasType.NORMAL;
			_fpsDisplay.gridFitType = GridFitType.PIXEL;
			#else
			#end
			_fpsDisplay.defaultTextFormat = new TextFormat("system",16,0xffffff,true,null,null,null,null,TextFormatAlign.RIGHT);
			addChild(_fpsDisplay);
			
			_extraDisplay = new TextField();
			_extraDisplay.width = 100;
			_extraDisplay.x = tmp.width-100;
			_extraDisplay.height = 64;
			_extraDisplay.y = 20;
			_extraDisplay.alpha = 0.5;
			_extraDisplay.multiline = true;
			_extraDisplay.wordWrap = true;
			_extraDisplay.selectable = false;
			#if flash9
			_extraDisplay.embedFonts = true;
			_extraDisplay.antiAliasType = AntiAliasType.NORMAL;
			_extraDisplay.gridFitType = GridFitType.PIXEL;
			#else
			#end
			_extraDisplay.defaultTextFormat = new TextFormat("system",8,0xffffff,true,null,null,null,null,TextFormatAlign.RIGHT);
			addChild(_extraDisplay);
			
			_lines = new Array();
		}
		
		/**
		 * Logs data to the developer console
		 * 
		 * @param	Text	The text that you wanted to write to the console
		 */
		public function log(Text:String):Void
		{
			if(Text == null)
				Text = "NULL";
			//trace(Text);
			_lines.push(Text);
			if(_lines.length > MAX_CONSOLE_LINES)
			{
				_lines.shift();
				var newText:String = "";
				for (i in 0 ... _lines.length)
					newText += _lines[i]+"\n";
				_text.text = newText;
			}
			else {
				#if flash9
				_text.appendText(Text+"\n");
				#else
				#end
			}
			_text.scrollV = Math.floor(_text.height);
		}
		
		/**
		 * Shows/hides the console.
		 */
		public function toggle():Void
		{
			if(_YT == _by)
				_YT = _byt;
			else
			{
				_YT = _by;
				visible = true;
			}
		}
		
		/**
		 * Updates and/or animates the dev console.
		 */
		public function update():Void
		{
			var total:Int = Math.floor(mtrTotal.average());
			_fpsDisplay.text = Math.floor(1000/total) + " fps";
			var up:Int = Math.floor(mtrUpdate.average());
			var rn:Int = Math.floor(mtrRender.average());
			var fx:Int = up+rn;
			var tt:Int = Math.floor(total);
			_extraDisplay.text = up + "ms update\n" + rn + "ms render\n" + fx + "ms flixel\n" + (tt-fx) + "ms flash\n" + tt + "ms total";
			
			if(_Y < _YT)
				_Y += FlxG.height*10*FlxG.elapsed;
			else if(_Y > _YT)
				_Y -= FlxG.height*10*FlxG.elapsed;
			if(_Y > _by)
				_Y = _by;
			else if(_Y < _byt)
			{
				_Y = _byt;
				visible = false;
			}
			y = Math.floor(_Y);
		}
	}
