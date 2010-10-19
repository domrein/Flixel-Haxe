package org.flixel;

	import flash.events.MouseEvent;
	
	/**
	 * A simple button class that calls a function when clicked by the mouse.
	 * Supports labels, highlight states, and parallax scrolling.
	 */
	class FlxButton extends FlxGroup {
		/**
		 * Used for checkbox-style behavior.
		 */
		
		public var on(getOn, setOn) : Bool;
		/**
		 * Used for checkbox-style behavior.
		 */
		var _onToggle:Bool;
		/**
		 * Stores the 'off' or normal button state graphic.
		 */
		var _off:FlxSprite;
		/**
		 * Stores the 'on' or highlighted button state graphic.
		 */
		var _on:FlxSprite;
		/**
		 * Stores the 'off' or normal button state label.
		 */
		var _offT:FlxText;
		/**
		 * Stores the 'on' or highlighted button state label.
		 */
		var _onT:FlxText;
		/**
		 * This function is called when the button is clicked.
		 */
		var _callback:Dynamic;
		/**
		 * Tracks whether or not the button is currently pressed.
		 */
		var _pressed:Bool;
		/**
		 * Whether or not the button has initialized itself yet.
		 */
		var _initialized:Bool;
		/**
		 * Helper variable for correcting its members' <code>scrollFactor</code> objects.
		 */
		var _sf:FlxPoint;
		
		/**
		 * Creates a new <code>FlxButton</code> object with a gray background
		 * and a callback function on the UI thread.
		 * 
		 * @param	X			The X position of the button.
		 * @param	Y			The Y position of the button.
		 * @param	Callback	The function to call whenever the button is clicked.
		 */
		public function new(X:Int,Y:Int,Callback:Dynamic)
		{
			super();
			x = X;
			y = Y;
			width = 100;
			height = 20;
			_off = new FlxSprite().createGraphic(Math.floor(width),Math.floor(height),0xff7f7f7f);
			_off.solid = false;
			add(_off,true);
			_on  = new FlxSprite().createGraphic(Math.floor(width),Math.floor(height),0xffffffff);
			_on.solid = false;
			add(_on,true);
			_offT = null;
			_onT = null;
			_callback = Callback;
			_onToggle = false;
			_pressed = false;
			_initialized = false;
			_sf = null;
		}
		
		/**
		 * Set your own image as the button background.
		 * 
		 * @param	Image				A FlxSprite object to use for the button background.
		 * @param	ImageHighlight		A FlxSprite object to use for the button background when highlighted (optional).
		 * 
		 * @return	This FlxButton instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadGraphic(Image:FlxSprite,?ImageHighlight:FlxSprite=null):FlxButton
		{
			_off = cast( replace(_off,Image), FlxSprite);
			if(ImageHighlight == null)
			{
				if(_on != _off)
					remove(_on);
				_on = _off;
			}
			else
				_on = cast( replace(_on,ImageHighlight), FlxSprite);
			_on.solid = _off.solid = false;
			_off.scrollFactor = scrollFactor;
			_on.scrollFactor = scrollFactor;
			width = _off.width;
			height = _off.height;
			refreshHulls();
			return this;
		}

		/**
		 * Add a text label to the button.
		 * 
		 * @param	Text				A FlxText object to use to display text on this button (optional).
		 * @param	TextHighlight		A FlxText object that is used when the button is highlighted (optional).
		 * 
		 * @return	This FlxButton instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadText(Text:FlxText,?TextHighlight:FlxText=null):FlxButton
		{
			if(Text != null)
			{
				if(_offT == null)
				{
					_offT = Text;
					add(_offT);
				}
				else
					_offT = cast( replace(_offT,Text), FlxText);
			}
			if(TextHighlight == null)
				_onT = _offT;
			else
			{
				if(_onT == null)
				{
					_onT = TextHighlight;
					add(_onT);
				}
				else
					_onT = cast( replace(_onT,TextHighlight), FlxText);
			}
			_offT.scrollFactor = scrollFactor;
			_onT.scrollFactor = scrollFactor;
			return this;
		}
		
		/**
		 * Called by the game loop automatically, handles mouseover and click detection.
		 */
		public override function update():Void
		{
			if(!_initialized)
			{
				if(FlxG.stage != null)
				{
					FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					_initialized = true;
				}
			}
			
			super.update();

			visibility(false);
			if(overlapsPoint(FlxG.mouse.x,FlxG.mouse.y))
			{
				if(!FlxG.mouse.pressed())
					_pressed = false;
				else if(!_pressed)
					_pressed = true;
				visibility(!_pressed);
			}
			if(_onToggle) visibility(_off.visible);
		}
		
		/**
		 * Use this to toggle checkbox-style behavior.
		 */
		public function getOn():Bool{
			return _onToggle;
		}
		
		/**
		 * @private
		 */
		public function setOn(On:Bool):Bool{
			_onToggle = On;
			return On;
		}
		
		/**
		 * Called by the game state when state is changed (if this object belongs to the state)
		 */
		public override function destroy():Void
		{
			if(FlxG.stage != null)
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		/**
		 * Internal function for handling the visibility of the off and on graphics.
		 * 
		 * @param	On		Whether the button should be on or off.
		 */
		function visibility(On:Bool):Void
		{
			if(On)
			{
				_off.visible = false;
				if(_offT != null) _offT.visible = false;
				_on.visible = true;
				if(_onT != null) _onT.visible = true;
			}
			else
			{
				_on.visible = false;
				if(_onT != null) _onT.visible = false;
				_off.visible = true;
				if(_offT != null) _offT.visible = true;
			}
		}
		
		/**
		 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
		 */
		function onMouseUp(event:MouseEvent):Void
		{
			if(!exists || !visible || !active || !FlxG.mouse.justReleased() || (_callback == null)) return;
			if(overlapsPoint(FlxG.mouse.x,FlxG.mouse.y)) _callback();
		}
	}
