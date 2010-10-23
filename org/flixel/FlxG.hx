package org.flixel;

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import org.flixel.data.FlxMouse;
	import org.flixel.data.FlxKeyboard;
	import org.flixel.data.FlxKong;
	import org.flixel.data.FlxPanel;
	import org.flixel.data.FlxQuake;
	import org.flixel.data.FlxFlash;
	import org.flixel.data.FlxFade;
	
	/**
	 * This is a global helper class full of useful functions for audio,
	 * input, basic info, and the camera system among other things.
	 */
	class FlxG
	 {
		/**
		 * If you build and maintain your own version of flixel,
		 * you can give it your own name here.  Appears in the console.
		 */
		public function new() { }
		
		public static var framerate(getFramerate, setFramerate) : Int;
		public static var frameratePaused(getFrameratePaused, setFrameratePaused) : Int;
		public static var mute(getMute, setMute) : Bool;
		public static var pause(getPause, setPause) : Bool;
		public static var showBounds(getShowBounds, setShowBounds) : Bool;
		public static var stage(getStage, null) : Stage
		;
		public static var state(getState, setState) : FlxState;
		public static var volume(getVolume, setVolume) : Float;
		/**
		 * If you build and maintain your own version of flixel,
		 * you can give it your own name here.  Appears in the console.
		 */
		public static var LIBRARY_NAME:String = "flixel";
		/**
		 * Assign a major version to your library.
		 * Appears before the decimal in the console.
		 */
		public static var LIBRARY_MAJOR_VERSION:Int = 2;
		/**
		 * Assign a minor version to your library.
		 * Appears after the decimal in the console.
		 */
		public static var LIBRARY_MINOR_VERSION:Int = 35;

		/**
		 * Internal tracker for game object (so we can pause & unpause)
		 */
		static var _game:FlxGame;
		/**
		 * Internal tracker for game pause state.
		 */
		static var _pause:Bool;
		/**
		 * Whether you are running in Debug or Release mode.
		 * Set automatically by <code>FlxFactory</code> during startup.
		 */
		public static var debug:Bool;
		/**
		 * Internal tracker for bounding box visibility.
		 */
		static var _showBounds:Bool;
		
		/**
		 * Represents the amount of time in seconds that passed since last frame.
		 */
		public static var elapsed:Float;
		/**
		 * Essentially locks the framerate to a minimum value - any slower and you'll get slowdown instead of frameskip; default is 1/30th of a second.
		 */
		public static var maxElapsed:Float;
		/**
		 * How fast or slow time should pass in the game; default is 1.0.
		 */
		public static var timeScale:Float;
		/**
		 * The width of the screen in game pixels.
		 */
		public static var width:Int;
		/**
		 * The height of the screen in game pixels.
		 */
		public static var height:Int;
		/**
		 * <code>FlxG.levels</code> and <code>FlxG.scores</code> are generic
		 * global variables that can be used for various cross-state stuff.
		 */
		public static var levels:Array<Dynamic>;
		public static var level:Int;
		public static var scores:Array<Dynamic>;
		public static var score:Int;
		/**
		 * <code>FlxG.saves</code> is a generic bucket for storing
		 * FlxSaves so you can access them whenever you want.
		 */
		public static var saves:Array<Dynamic>; 
		public static var save:Int;

		/**
		 * A reference to a <code>FlxMouse</code> object.  Important for input!
		 */
		public static var mouse:FlxMouse;
		/**
		 * A reference to a <code>FlxKeyboard</code> object.  Important for input!
		 */
		public static var keys:FlxKeyboard;
		
		/**
		 * A handy container for a background music object.
		 */
		public static var music:FlxSound;
		/**
		 * A list of all the sounds being played in the game.
		 */
		public static var sounds:Array<Dynamic>;
		/**
		 * Internal flag for whether or not the game is muted.
		 */
		static var _mute:Bool;
		/**
		 * Internal volume level, used for global sound control.
		 */
		static var _volume:Float;
		
		/**
		 * Tells the camera to follow this <code>FlxCore</code> object around.
		 */
		public static var followTarget:FlxObject;
		/**
		 * Used to force the camera to look ahead of the <code>followTarget</code>.
		 */
		public static var followLead:Point;
		/**
		 * Used to smoothly track the camera as it follows.
		 */
		public static var followLerp:Float;
		/**
		 * Stores the top and left edges of the camera area.
		 */
		public static var followMin:Point;
		/**
		 * Stores the bottom and right edges of the camera area.
		 */
		public static var followMax:Point;
		/**
		 * Internal, used to assist camera and scrolling.
		 */
		static var _scrollTarget:Point;
		
		/**
		 * Stores the basic parallax scrolling values.
		 */
		public static var scroll:Point;
		/**
		 * Reference to the active graphics buffer.
		 * Can also be referenced via <code>FlxState.screen</code>.
		 */
		public static var buffer:BitmapData;
		/**
		 * Internal storage system to prevent graphics from being used repeatedly in memory.
		 */
		static var _cache:Dynamic;
		
		/**
		 * Access to the Kongregate high scores and achievements API.
		 */
		public static var kong:FlxKong;
		
		/**
		 * The support panel (twitter, reddit, stumbleupon, paypal, etc) visor thing
		 */
		public static var panel:FlxPanel;
		/**
		 * A special effect that shakes the screen.  Usage: FlxG.quake.start();
		 */
		public static var quake:FlxQuake;
		/**
		 * A special effect that flashes a color on the screen.  Usage: FlxG.flash.start();
		 */
		public static var flash:FlxFlash;
		/**
		 * A special effect that fades a color onto the screen.  Usage: FlxG.fade.start();
		 */
		public static var fade:FlxFade;
		
		/**
		 * Log data to the developer console.
		 * 
		 * @param	Data		Anything you want to log to the console.
		 */
		public static function log(Data:Dynamic):Void
		{
			if((_game != null) && (_game._console != null))
				_game._console.log((Data == null)?"ERROR: null object":Data.toString());
		}
		
		/**
		 * Set <code>pause</code> to true to pause the game, all sounds, and display the pause popup.
		 */
		public static function getPause():Bool{
			return _pause;
		}
		
		/**
		 * @private
		 */
		public static function setPause(Pause:Bool):Bool{
			var op:Bool = _pause;
			_pause = Pause;
			if(_pause != op)
			{
				if(_pause)
				{
					_game.pauseGame();
					pauseSounds();
				}
				else
				{
					_game.unpauseGame();
					playSounds();
				}
			}
			return Pause;
		}
		
		/**
		 * Set <code>showBounds</code> to true to display the bounding boxes of the in-game objects.
		 */
		public static function getShowBounds():Bool{
			return _showBounds;
		}
		
		/**
		 * @private
		 */
		public static function setShowBounds(ShowBounds:Bool):Bool{
			var osb:Bool = _showBounds;
			_showBounds = ShowBounds;
			if(_showBounds != osb)
				FlxObject._refreshBounds = true;
			return ShowBounds;
		}
		
		/**
		 * The game and SWF framerate; default is 60.
		 */
		public static function getFramerate():Int{
			return _game._framerate;
		}
		
		/**
		 * @private
		 */
		public static function setFramerate(Framerate:Int):Int{
			_game._framerate = Framerate;
			if(!_game._paused && (_game.stage != null))
				_game.stage.frameRate = Framerate;
			return Framerate;
		}
		
		/**
		 * The game and SWF framerate while paused; default is 10.
		 */
		public static function getFrameratePaused():Int{
			return _game._frameratePaused;
		}
		
		/**
		 * @private
		 */
		public static function setFrameratePaused(Framerate:Int):Int{
			_game._frameratePaused = Framerate;
			if(_game._paused && (_game.stage != null))
				_game.stage.frameRate = Framerate;
			return Framerate;
		}
		
		/**
		 * Reset the input helper objects (useful when changing screens or states)
		 */
		public static function resetInput():Void
		{
			keys.reset();
			mouse.reset();
		}
		
		/**
		 * Set up and play a looping background soundtrack.
		 * 
		 * @param	Music		The sound file you want to loop in the background.
		 * @param	Volume		How loud the sound should be, from 0 to 1.
		 */
		public static function playMusic(Music:Class<Dynamic>,?Volume:Float=1.0):Void
		{
			if(music == null)
				music = new FlxSound();
			else if(music.active)
				music.stop();
			music.loadEmbedded(Music,true);
			music.volume = Volume;
			music.survive = true;
			music.play();
		}
		
		/**
		 * Creates a new sound object from an embedded <code>Class</code> object.
		 * 
		 * @param	EmbeddedSound	The sound you want to play.
		 * @param	Volume			How loud to play it (0 to 1).
		 * @param	Looped			Whether or not to loop this sound.
		 * 
		 * @return	A <code>FlxSound</code> object.
		 */
		public static function play(EmbeddedSound:Class<Dynamic>,?Volume:Float=1.0,?Looped:Bool=false):FlxSound
		{
			var sl:Int = sounds.length;
			var index:Int = -1;
			for (i in 0 ... sl) {
				if(!(cast( sounds[i], FlxSound)).active) {
					break;
					index = i;
				}
			}
			if(sounds[index] == null)
				sounds[index] = new FlxSound();
			var s:FlxSound = sounds[index];
			s.loadEmbedded(EmbeddedSound,Looped);
			s.volume = Volume;
			s.play();
			return s;
		}
		
		/**
		 * Creates a new sound object from a URL.
		 * 
		 * @param	EmbeddedSound	The sound you want to play.
		 * @param	Volume			How loud to play it (0 to 1).
		 * @param	Looped			Whether or not to loop this sound.
		 * 
		 * @return	A FlxSound object.
		 */
		public static function stream(URL:String,?Volume:Float=1.0,?Looped:Bool=false):FlxSound
		{
			var sl:Int = sounds.length;
			var index:Int = -1;
			for (i in 0 ... sl) {
				if(!(cast( sounds[i], FlxSound)).active) {
					index = i;
					break;
				}
			}
			if(sounds[index] == null)
				sounds[index] = new FlxSound();
			var s:FlxSound = sounds[index];
			s.loadStream(URL,Looped);
			s.volume = Volume;
			s.play();
			return s;
		}
		
		/**
		 * Set <code>mute</code> to true to turn off the sound.
		 * 
		 * @default false
		 */
		public static function getMute():Bool{
			return _mute;
		}
		
		/**
		 * @private
		 */
		public static function setMute(Mute:Bool):Bool{
			_mute = Mute;
			changeSounds();
			return Mute;
		}
		
		/**
		 * Get a number that represents the mute state that we can multiply into a sound transform.
		 * 
		 * @return		An unsigned integer - 0 if muted, 1 if not muted.
		 */
		public static function getMuteValue():Int
		{
			if(_mute)
				return 0;
			else
				return 1;
		}
		
		/**
		 * Set <code>volume</code> to a number between 0 and 1 to change the global volume.
		 * 
		 * @default 0.5
		 */
		 public static function getVolume():Float{ return _volume; }
		 
		/**
		 * @private
		 */
		public static function setVolume(Volume:Float):Float{
			_volume = Volume;
			if(_volume < 0)
				_volume = 0;
			else if(_volume > 1)
				_volume = 1;
			changeSounds();
			return Volume;
		}

		/**
		 * Called by FlxGame on state changes to stop and destroy sounds.
		 * 
		 * @param	ForceDestroy		Kill sounds even if they're flagged <code>survive</code>.
		 */
		public static function destroySounds(?ForceDestroy:Bool=false):Void
		{
			if(sounds == null)
				return;
			if((music != null) && (ForceDestroy || !music.survive))
				music.destroy();
			var s:FlxSound;
			var sl:Int = sounds.length;
			for(i in 0...sl)
			{
				s = cast( sounds[i], FlxSound);
				if((s != null) && (ForceDestroy || !s.survive))
					s.destroy();
			}
		}

		/**
		 * An internal function that adjust the volume levels and the music channel after a change.
		 */
		static function changeSounds():Void
		{
			if((music != null) && music.active)
				music.updateTransform();
			var s:FlxSound;
			var sl:Int = sounds.length;
			for(i in 0...sl)
			{
				s = cast( sounds[i], FlxSound);
				if((s != null) && s.active)
					s.updateTransform();
			}
		}
		
		/**
		 * Called by the game loop to make sure the sounds get updated each frame.
		 */
		public static function updateSounds():Void
		{
			if((music != null) && music.active)
				music.update();
			var s:FlxSound;
			var sl:Int = sounds.length;
			for(i in 0...sl)
			{
				s = cast( sounds[i], FlxSound);
				if((s != null) && s.active)
					s.update();
			}
		}
		
		/**
		 * Internal helper, pauses all game sounds.
		 */
		static function pauseSounds():Void
		{
			if((music != null) && music.active)
				music.pause();
			var s:FlxSound;
			var sl:Int = sounds.length;
			for(i in 0...sl)
			{
				s = cast( sounds[i], FlxSound);
				if((s != null) && s.active)
					s.pause();
			}
		}
		
		/**
		 * Internal helper, pauses all game sounds.
		 */
		static function playSounds():Void
		{
			if((music != null) && music.active)
				music.play();
			var s:FlxSound;
			var sl:Int = sounds.length;
			for(i in 0...sl)
			{
				s = cast( sounds[i], FlxSound);
				if((s != null) && s.active)
					s.play();
			}
		}
		
		/**
		 * Check the local bitmap cache to see if a bitmap with this key has been loaded already.
		 *
		 * @param	Key		The string key identifying the bitmap.
		 * 
		 * @return	Whether or not this file can be found in the cache.
		 */
		public static function checkBitmapCache(Key:String):Bool
		{
			return (Reflect.hasField(_cache, Key)) && (Reflect.field(_cache, Key) != null);
		}
		
		/**
		 * Generates a new <code>BitmapData</code> object (a colored square) and caches it.
		 * 
		 * @param	Width	How wide the square should be.
		 * @param	Height	How high the square should be.
		 * @param	Color	What color the square should be (0xAARRGGBB)
		 * 
		 * @return	The <code>BitmapData</code> we just created.
		 */
		public static function createBitmap(Width:Int, Height:Int, Color:Int, ?Unique:Bool=false, ?Key:String=null):BitmapData
		{
			var key:String = Key;
			if(key == null)
			{
				key = Width+"x"+Height+":"+Color;
				if(Unique && (Reflect.hasField(_cache, key)) && (Reflect.field(_cache, key) != null))
				{
					//Generate a unique key
					var inc:Int = 0;
					var ukey:String;
					do { ukey = key + inc++;
					} while((Reflect.hasField(_cache, ukey)) && (Reflect.field(_cache, ukey) != null));
					key = ukey;
				}
			}
			if(!checkBitmapCache(key))
				Reflect.setField(_cache, key, new BitmapData(Width,Height,true,Color));
			return Reflect.field(_cache, key);
		}
		
		/**
		 * Loads a bitmap from a file, caches it, and generates a horizontally flipped version if necessary.
		 * 
		 * @param	Graphic		The image file that you want to load.
		 * @param	Reverse		Whether to generate a flipped version.
		 * 
		 * @return	The <code>BitmapData</code> we just created.
		 */
		public static function addBitmap(Graphic:Class<Dynamic>, ?Reverse:Bool=false, ?Unique:Bool=false, ?Key:String=null):BitmapData
		{
			var needReverse:Bool = false;
			var key:String = Key;
			if(key == null)
			{
				key = Type.getClassName(Graphic);
				if(Unique && (Reflect.hasField(_cache, key)) && (Reflect.field(_cache, key) != null))
				{
					//Generate a unique key
					var inc:Int = 0;
					var ukey:String;
					do { ukey = key + inc++;
					} while((Reflect.hasField(_cache, ukey)) && (Reflect.field(_cache, ukey) != null));
					key = ukey;
				}
			}
			//If there is no data for this key, generate the requested graphic
			if(!checkBitmapCache(key))
			{
				Reflect.setField(_cache, key, Type.createInstance(Graphic, []).bitmapData);
				if(Reverse) needReverse = true;
			}
			var pixels:BitmapData = Reflect.field(_cache, key);
			if(!needReverse && Reverse && (pixels.width == Type.createInstance(Graphic, []).bitmapData.width))
				needReverse = true;
			if(needReverse)
			{
				var newPixels:BitmapData = new BitmapData(pixels.width<<1,pixels.height,true,0x00000000);
				newPixels.draw(pixels);
				var mtx:Matrix = new Matrix();
				mtx.scale(-1,1);
				mtx.translate(newPixels.width,0);
				newPixels.draw(pixels,mtx);
				pixels = newPixels;
			}
			return pixels;
		}

		/**
		 * Tells the camera subsystem what <code>FlxCore</code> object to follow.
		 * 
		 * @param	Target		The object to follow.
		 * @param	Lerp		How much lag the camera should have (can help smooth out the camera movement).
		 */
		public static function follow(Target:FlxObject, ?Lerp:Float=1):Void
		{
			followTarget = Target;
			followLerp = Lerp;
			_scrollTarget.x = (Math.floor(width)>>1)-followTarget.x-(Math.floor(followTarget.width)>>1);
			_scrollTarget.y = (Math.floor(height)>>1)-followTarget.y-(Math.floor(followTarget.height)>>1);
			scroll.x = _scrollTarget.x;
			scroll.y = _scrollTarget.y;
			doFollow();
		}
		
		/**
		 * Specify an additional camera component - the velocity-based "lead",
		 * or amount the camera should track in front of a sprite.
		 * 
		 * @param	LeadX		Percentage of X velocity to add to the camera's motion.
		 * @param	LeadY		Percentage of Y velocity to add to the camera's motion.
		 */
		public static function followAdjust(?LeadX:Float = 0, ?LeadY:Float = 0):Void
		{
			followLead = new Point(LeadX,LeadY);
		}
		
		/**
		 * Specify the boundaries of the level or where the camera is allowed to move.
		 * 
		 * @param	MinX				The smallest X value of your level (usually 0).
		 * @param	MinY				The smallest Y value of your level (usually 0).
		 * @param	MaxX				The largest X value of your level (usually the level width).
		 * @param	MaxY				The largest Y value of your level (usually the level height).
		 * @param	UpdateWorldBounds	Whether the quad tree's dimensions should be updated to match.
		 */
		public static function followBounds(?MinX:Int=0, ?MinY:Int=0, ?MaxX:Int=0, ?MaxY:Int=0, ?UpdateWorldBounds:Bool=true):Void
		{
			followMin = new Point(-MinX,-MinY);
			followMax = new Point(-MaxX+width,-MaxY+height);
			if(followMax.x > followMin.x)
				followMax.x = followMin.x;
			if(followMax.y > followMin.y)
				followMax.y = followMin.y;
			if(UpdateWorldBounds)
				FlxU.setWorldBounds(MinX,MinY,MaxX-MinX,MaxY-MinY);
			doFollow();
		}
		
		/**
		 * Retrieves the Flash stage object (required for event listeners)
		 * 
		 * @return	A Flash <code>MovieClip</code> object.
		 */
		public static function getStage():Stage
		{
			if((_game._state != null)  && (_game._state.parent != null))
				return _game._state.parent.stage;
			return null;
		}
		
		/**
		 * Safely access the current game state.
		 */
		public static function getState():FlxState{
			return _game._state;
		}
		
		/**
		 * @private
		 */
		public static function setState(State:FlxState):FlxState{
			_game.switchState(State);
			return State;
		}

		/**
		 * Called by <code>FlxGame</code> to set up <code>FlxG</code> during <code>FlxGame</code>'s constructor.
		 */
		public static function setGameData(Game:FlxGame,Width:Int,Height:Int,Zoom:Int):Void
		{
			_game = Game;
			_cache = {};
			width = Width;
			height = Height;
			_mute = false;
			_volume = 0.5;
			sounds = new Array();
			mouse = new FlxMouse();
			keys = new FlxKeyboard();
			scroll = null;
			_scrollTarget = null;
			unfollow();
			FlxG.levels = new Array();
			FlxG.scores = new Array();
			level = 0;
			score = 0;
			FlxU.seed = Math.NaN;
			kong = null;
			pause = false;
			timeScale = 1.0;
			framerate = 60;
			frameratePaused = 10;
			maxElapsed = 0.0333333;
			FlxG.elapsed = 0;
			_showBounds = false;
			FlxObject._refreshBounds = false;
			
			panel = new FlxPanel();
			quake = new FlxQuake(Zoom);
			flash = new FlxFlash();
			fade = new FlxFade();

			FlxU.setWorldBounds(0,0,FlxG.width,FlxG.height);
		}

		/**
		 * Internal function that updates the camera and parallax scrolling.
		 */
		public static function doFollow():Void
		{
			if(followTarget != null)
			{
				_scrollTarget.x = (Math.floor(width)>>1)-followTarget.x-(Math.floor(followTarget.width)>>1);
				_scrollTarget.y = (Math.floor(height)>>1)-followTarget.y-(Math.floor(followTarget.height)>>1);
				if((followLead != null) && (Std.is( followTarget, FlxSprite)))
				{
					_scrollTarget.x -= (cast( followTarget, FlxSprite)).velocity.x*followLead.x;
					_scrollTarget.y -= (cast( followTarget, FlxSprite)).velocity.y*followLead.y;
				}
				scroll.x += (_scrollTarget.x-scroll.x)*followLerp*FlxG.elapsed;
				scroll.y += (_scrollTarget.y-scroll.y)*followLerp*FlxG.elapsed;
				
				if(followMin != null)
				{
					if(scroll.x > followMin.x)
						scroll.x = followMin.x;
					if(scroll.y > followMin.y)
						scroll.y = followMin.y;
				}
				
				if(followMax != null)
				{
					if(scroll.x < followMax.x)
						scroll.x = followMax.x;
					if(scroll.y < followMax.y)
						scroll.y = followMax.y;
				}
			}
		}
		
		/**
		 * Stops and resets the camera.
		 */
		public static function unfollow():Void
		{
			followTarget = null;
			followLead = null;
			followLerp = 1;
			followMin = null;
			followMax = null;
			if(scroll == null)
				scroll = new Point();
			else
				scroll.x = scroll.y = 0;
			if(_scrollTarget == null)
				_scrollTarget = new Point();
			else
				_scrollTarget.x = _scrollTarget.y = 0;
		}
		
		/**
		 * Calls update on the keyboard and mouse input tracking objects.
		 */
		public static function updateInput():Void
		{
			keys.update();
			mouse.update(Math.floor(state.mouseX),Math.floor(state.mouseY),scroll.x,scroll.y);
		}
	}
