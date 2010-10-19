package org.flixel.data;

	import flash.events.KeyboardEvent;
	
	class FlxKeyboard
	 {
		
		public var ESCAPE:Bool;
		public var F1:Bool;
		public var F2:Bool;
		public var F3:Bool;
		public var F4:Bool;
		public var F5:Bool;
		public var F6:Bool;
		public var F7:Bool;
		public var F8:Bool;
		public var F9:Bool;
		public var F10:Bool;
		public var F11:Bool;
		public var F12:Bool;
		public var ONE:Bool;
		public var TWO:Bool;
		public var THREE:Bool;
		public var FOUR:Bool;
		public var FIVE:Bool;
		public var SIX:Bool;
		public var SEVEN:Bool;
		public var EIGHT:Bool;
		public var NINE:Bool;
		public var ZERO:Bool;
		public var MINUS:Bool;
		public var PLUS:Bool;
		public var DELETE:Bool;
		public var BACKSPACE:Bool;
		public var Q:Bool;
		public var W:Bool;
		public var E:Bool;
		public var R:Bool;
		public var T:Bool;
		public var Y:Bool;
		public var U:Bool;
		public var I:Bool;
		public var O:Bool;
		public var P:Bool;
		public var LBRACKET:Bool;
		public var RBRACKET:Bool;
		public var BACKSLASH:Bool;
		public var CAPSLOCK:Bool;
		public var A:Bool;
		public var S:Bool;
		public var D:Bool;
		public var F:Bool;
		public var G:Bool;
		public var H:Bool;
		public var J:Bool;
		public var K:Bool;
		public var L:Bool;
		public var SEMICOLON:Bool;
		public var QUOTE:Bool;
		public var ENTER:Bool;
		public var SHIFT:Bool;
		public var Z:Bool;
		public var X:Bool;
		public var C:Bool;
		public var V:Bool;
		public var B:Bool;
		public var N:Bool;
		public var M:Bool;
		public var COMMA:Bool;
		public var PERIOD:Bool;
		public var SLASH:Bool;
		public var CONTROL:Bool;
		public var ALT:Bool;
		public var SPACE:Bool;
		public var UP:Bool;
		public var DOWN:Bool;
		public var LEFT:Bool;
		public var RIGHT:Bool;
		
		/**
		 * @private
		 */
		var _lookup:Dynamic;
		/**
		 * @private
		 */
		var _map:Array<Dynamic>;
		/**
		 * @private
		 */
		var _t:Int ;
		
		/**
		 * Constructor
		 */
		public function new()
		{
			//BASIC STORAGE & TRACKING			
			
			_t = 256;
			var i:Int = 0;
			_lookup = {};
			_map = new Array<Dynamic>();
			for (i in 0 ... _t)
				_map.push(null);
			
			//LETTERS
			for (i in 65 ... 91)
				addKey(String.fromCharCode(i),i);
			
			//NUMBERS
			i = 48;
			addKey("ZERO",i++);
			addKey("ONE",i++);
			addKey("TWO",i++);
			addKey("THREE",i++);
			addKey("FOUR",i++);
			addKey("FIVE",i++);
			addKey("SIX",i++);
			addKey("SEVEN",i++);
			addKey("EIGHT",i++);
			addKey("NINE",i++);
			
			//FUNCTION KEYS
			for (i in 1 ... 13)
				addKey("F"+i,111+i);
			
			//SPECIAL KEYS + PUNCTUATION
			addKey("ESCAPE",27);
			addKey("MINUS",189);
			addKey("PLUS",187);
			addKey("DELETE",46);
			addKey("BACKSPACE",8);
			addKey("LBRACKET",219);
			addKey("RBRACKET",221);
			addKey("BACKSLASH",220);
			addKey("CAPSLOCK",20);
			addKey("SEMICOLON",186);
			addKey("QUOTE",222);
			addKey("ENTER",13);
			addKey("SHIFT",16);
			addKey("COMMA",188);
			addKey("PERIOD",190);
			addKey("SLASH",191);
			addKey("CONTROL",17);
			addKey("ALT",18);
			addKey("SPACE",32);
			addKey("UP",38);
			addKey("DOWN",40);
			addKey("LEFT",37);
			addKey("RIGHT",39);
		}
		
		/**
		 * Updates the key states (for tracking just pressed, just released, etc).
		 */
		public function update():Void
		{
			for(i in 0..._t)
			{
				if(_map[i] == null) continue;
				var o:Dynamic = _map[i];
				if((o.last == -1) && (o.current == -1)) o.current = 0;
				else if((o.last == 2) && (o.current == 2)) o.current = 1;
				o.last = o.current;
			}
		}
		
		/**
		 * Resets all the keys.
		 */
		public function reset():Void
		{
			for(i in 0..._t)
			{
				if(_map[i] == null) continue;
				var o:Dynamic = _map[i];
				Reflect.setField(this, o.name, false);
				o.current = 0;
				o.last = 0;
			}
		}
		
		/**
		 * Check to see if this key is pressed.
		 * 
		 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
		 * 
		 * @return	Whether the key is pressed
		 */
		public function pressed(Key:String):Bool { return Reflect.field(this, Key); }
		
		/**
		 * Check to see if this key was just pressed.
		 * 
		 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
		 * 
		 * @return	Whether the key was just pressed
		 */
		public function justPressed(Key:String):Bool { return _map[Reflect.field(_lookup, Key)].current == 2; }
		
		/**
		 * Check to see if this key is just released.
		 * 
		 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
		 * 
		 * @return	Whether the key is just released.
		 */
		public function justReleased(Key:String):Bool { return _map[Reflect.field(_lookup, Key)].current == -1; }
		
		/**
		 * Event handler so FlxGame can toggle keys.
		 * 
		 * @param	event	A <code>KeyboardEvent</code> object.
		 */
		public function handleKeyDown(event:KeyboardEvent):Void
		{
			var o:Dynamic = _map[event.keyCode];
			if(o == null) return;
			if(o.current > 0) o.current = 1;
			else o.current = 2;
			Reflect.setField(this, o.name, true);
		}
		
		/**
		 * Event handler so FlxGame can toggle keys.
		 * 
		 * @param	event	A <code>KeyboardEvent</code> object.
		 */
		public function handleKeyUp(event:KeyboardEvent):Void
		{
			var o:Dynamic = _map[event.keyCode];
			if(o == null) return;
			if(o.current > 0) o.current = -1;
			else o.current = 0;
			Reflect.setField(this, o.name, false);
		}
		
		/**
		 * An internal helper function used to build the key array.
		 * 
		 * @param	KeyName		String name of the key (e.g. "LEFT" or "A")
		 * @param	KeyCode		The numeric Flash code for this key.
		 */
		function addKey(KeyName:String,KeyCode:Int):Void
		{
			
			Reflect.setField(_lookup, KeyName, KeyCode);
			_map[KeyCode] = { name: KeyName, current: 0, last: 0 };
		}
	}
