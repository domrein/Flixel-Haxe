package org.flixel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.Lib;

import org.flixel.data.FlxConsole;
import org.flixel.data.FlxPause;

#if flash9
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.ui.Mouse;
import flash.utils.Timer;
#end
/**
 * FlxGame is the heart of all flixel games, and contains a bunch of basic game loops and things.
 * It is a long and sloppy file that you shouldn't have to worry about too much!
 * It is basically only used to create your game object in the first place,
 * after that FlxG and FlxState have all the useful stuff you actually need.
 */
class FlxGame extends Sprite {
	// NOTE: Flex 4 introduces DefineFont4, which is used by default and does not work in native text fields.
	// Use the embedAsCFF="false" param to switch back to DefineFont4. In earlier Flex 4 SDKs this was cff="false".
	// So if you are using the Flex 3.x SDK compiler, switch the embed statment below to expose the correct version.
	
	//Flex v4.x SDK only (see note above):
	
	// NOTE: Flex 4 introduces DefineFont4, which is used by default and does not work in native text fields.
	// Use the embedAsCFF="false" param to switch back to DefineFont4. In earlier Flex 4 SDKs this was cff="false".
	// So if you are using the Flex 3.x SDK compiler, switch the embed statment below to expose the correct version.
	
	//Flex v4.x SDK only (see note above):
	/*[Embed(source="data/nokiafc22.ttf",fontFamily="system",embedAsCFF="false")]*/ var junk:String;
	
	//Flex v3.x SDK only (see note above):
	//[Embed(source="data/nokiafc22.ttf",fontFamily="system")] protected var junk:String;
	
	/*[Embed(source="data/beep.mp3")]*/ var SndBeep:Class<Dynamic>;
	/*[Embed(source="data/flixel.mp3")]*/ var SndFlixel:Class<Dynamic>;

	/**
	 * Sets 0, -, and + to control the global volume and P to pause.
	 * @default true
	 */
	public var useDefaultHotKeys:Bool;
	/**
	 * Displayed whenever the game is paused.
	 * Override with your own <code>FlxLayer</code> for hot custom pause action!
	 * Defaults to <code>data.FlxPause</code>.
	 */
	public var pause:FlxGroup;
	
	//startup
	public var _iState:Class<Dynamic>;
	public var _created:Bool;
	
	//basic display stuff
	public var _state:FlxState;
	public var _screen:Sprite;
	public var _buffer:Bitmap;
	public var _zoom:Int;
	public var _gameXOffset:Int;
	public var _gameYOffset:Int;
	public var _frame:Class<Dynamic>;
	public var _zeroPoint:Point;
	
	//basic update stuff
	public var _elapsed:Float;
	public var _total:Int;
	public var _paused:Bool;
	public var _framerate:Int;
	public var _frameratePaused:Int;
	
	//Pause screen, sound tray, support panel, dev console, and special effects objects
	public var _soundTray:Sprite;
	public var _soundTrayTimer:Float;
	public var _soundTrayBars:Array<Dynamic>;
	public var _console:FlxConsole;
	
	/**
	 * Game object constructor - sets up the basic properties of your game.
	 * 
	 * @param	GameSizeX		The width of your game in pixels (e.g. 320).
	 * @param	GameSizeY		The height of your game in pixels (e.g. 240).
	 * @param	InitialState	The class name of the state you want to create and switch to first (e.g. MenuState).
	 * @param	Zoom			The level of zoom (e.g. 2 means all pixels are now rendered twice as big).
	 */
	public function new(GameSizeX:Int,GameSizeY:Int,InitialState:Class<Dynamic>,?Zoom:Int=2)
	{
		super();
		
		#if flash9
		flash.ui.Mouse.hide();
		#end
		
		_zoom = Zoom;
		FlxState.bgColor = 0xff000000;
		FlxG.setGameData(this,GameSizeX,GameSizeY,Zoom);
		_elapsed = 0;
		_total = 0;
		pause = new FlxPause();
		_state = null;
		_iState = InitialState;
		_zeroPoint = new Point();

		useDefaultHotKeys = true;
		
		_frame = null;
		_gameXOffset = 0;
		_gameYOffset = 0;
		
		_paused = false;
		_created = false;
		
		addEventListener(Event.ENTER_FRAME, create);
	}
	
	/**
	 * Adds a frame around your game for presentation purposes (see Canabalt, Gravity Hook).
	 * 
	 * @param	Frame			If you want you can add a little graphical frame to the outside edges of your game.
	 * @param	ScreenOffsetX	Width in pixels of left side of frame.
	 * @param	ScreenOffsetY	Height in pixels of top of frame.
	 * 
	 * @return	This <code>FlxGame</code> instance.
	 */
	function addFrame(Frame:Class<Dynamic>,ScreenOffsetX:Int,ScreenOffsetY:Int):FlxGame
	{
		_frame = Frame;
		_gameXOffset = ScreenOffsetX;
		_gameYOffset = ScreenOffsetY;
		return this;
	}
	
	/**
	 * Makes the little volume tray slide out.
	 * 
	 * @param	Silent	Whether or not it should beep.
	 */
	public function showSoundTray(?Silent:Bool=false):Void
	{
		if(!Silent)
			FlxG.play(SndBeep);
		_soundTrayTimer = 1;
		_soundTray.y = _gameYOffset*_zoom;
		_soundTray.visible = true;
		var gv:Int = Math.round(FlxG.volume*10);
		if(FlxG.mute)
			gv = 0;
		for (i in 0..._soundTrayBars.length)
		{
			if(i < gv) _soundTrayBars[i].alpha = 1;
			else _soundTrayBars[i].alpha = 0.5;
		}
	}
	
	/**
	 * Switch from one <code>FlxState</code> to another.
	 * Usually called from <code>FlxG</code>.
	 * 
	 * @param	State		The class name of the state you want (e.g. PlayState)
	 */
	public function switchState(State:FlxState):Void
	{ 
		//Basic reset stuff
		FlxG.panel.hide();
		FlxG.unfollow();
		FlxG.resetInput();
		FlxG.destroySounds();
		FlxG.flash.stop();
		FlxG.fade.stop();
		FlxG.quake.stop();
		_screen.x = 0;
		_screen.y = 0;
		
		//Swap the new state for the old one and dispose of it
		_screen.addChild(State);
		if(_state != null)
		{
			_state.destroy(); //important that it is destroyed while still in the display list
			_screen.swapChildren(State,_state);
			_screen.removeChild(_state);
		}
		_state = State;
		_state.scaleX = _state.scaleY = _zoom;
		
		//Finally, create the new state
		_state.create();
	}

	/**
	 * Internal event handler for input and focus.
	 */
	function onKeyUp(event:KeyboardEvent):Void
	{
		if((event.keyCode == 192) || (event.keyCode == 220)) //FOR ZE GERMANZ
		{
			_console.toggle();
			return;
		}
		if(useDefaultHotKeys)
		{
			var c:Int = event.keyCode;
			var code:String = String.fromCharCode(event.charCode);
			switch(c)
			{
				case 48:
				case 96:
					FlxG.mute = !FlxG.mute;
					showSoundTray();
					return;
				case 109:
				case 189:
					FlxG.mute = false;
		    		FlxG.volume = FlxG.volume - 0.1;
		    		showSoundTray();
					return;
				case 107:
				case 187:
					FlxG.mute = false;
		    		FlxG.volume = FlxG.volume + 0.1;
		    		showSoundTray();
					return;
				case 80:
					FlxG.pause = !FlxG.pause;
				default:
			}
		}
		FlxG.keys.handleKeyUp(event);
	}
	
	/**
	 * Internal event handler for input and focus.
	 */
	function onFocus(?event:Event=null):Void
	{
		if(FlxG.pause)
			FlxG.pause = false;
	}
	
	/**
	 * Internal event handler for input and focus.
	 */
	function onFocusLost(?event:Event=null):Void
	{
		FlxG.pause = true;
	}
	
	/**
	 * Internal function to help with basic pause game functionality.
	 */
	public function unpauseGame():Void
	{
		#if flash9
		if(!FlxG.panel.visible) flash.ui.Mouse.hide();
		#end
		FlxG.resetInput();
		_paused = false;
		stage.frameRate = _framerate;
	}
	
	/**
	 * Internal function to help with basic pause game functionality.
	 */
	public function pauseGame():Void
	{
		if((x != 0) || (y != 0))
		{
			x = 0;
			y = 0;
		}
		#if flash9
		flash.ui.Mouse.show();
		#end
		_paused = true;
		stage.frameRate = _frameratePaused;
	}
	
	/**
	 * This is the main game loop.  It controls all the updating and rendering.
	 */
	function update(event:Event):Void
	{
		var mark:Int = Lib.getTimer();
		
		var i:Int;
		var soundPrefs:FlxSave;

		//Frame timing
		var ems:Int = mark-_total;
		_elapsed = ems/1000;
		_console.mtrTotal.add(ems);
		_total = mark;
		FlxG.elapsed = _elapsed;
		if(FlxG.elapsed > FlxG.maxElapsed)
			FlxG.elapsed = FlxG.maxElapsed;
		FlxG.elapsed *= FlxG.timeScale;
		
		//Sound tray crap
		if(_soundTray != null)
		{
			if(_soundTrayTimer > 0)
				_soundTrayTimer -= _elapsed;
			else if(_soundTray.y > -_soundTray.height)
			{
				_soundTray.y -= _elapsed*FlxG.height*2;
				if(_soundTray.y <= -_soundTray.height)
				{
					_soundTray.visible = false;
					
					//Save sound preferences
					soundPrefs = new FlxSave();
					if(soundPrefs.bind("flixel"))
					{
						if(soundPrefs.data.sound == null)
							soundPrefs.data.sound = {};
						soundPrefs.data.mute = FlxG.mute;
						soundPrefs.data.volume = FlxG.volume;
						soundPrefs.forceSave();
					}
				}
			}
		}

		//Animate flixel HUD elements
		FlxG.panel.update();
		if(_console.visible)
			_console.update();
		
		//State updating
		FlxObject._refreshBounds = false;
		FlxG.updateInput();
		FlxG.updateSounds();
		if(_paused)
			pause.update();
		else
		{
			//Update the camera and game state
			FlxG.doFollow();
			_state.update();
			
			//Update the various special effects
			if(FlxG.flash.exists)
				FlxG.flash.update();
			if(FlxG.fade.exists)
				FlxG.fade.update();
			FlxG.quake.update();
			_screen.x = FlxG.quake.x;
			_screen.y = FlxG.quake.y;
		}
		//Keep track of how long it took to update everything
		var updateMark:Int = Lib.getTimer();
		_console.mtrUpdate.add(updateMark-mark);
		
		//Render game content, special fx, and overlays
		FlxG.buffer.lock();
		_state.preProcess();
		_state.render();
		if(FlxG.flash.exists)
			FlxG.flash.render();
		if(FlxG.fade.exists)
			FlxG.fade.render();
		if(FlxG.panel.visible)
			FlxG.panel.render();
		if(FlxG.mouse.cursor != null)
		{
			if(FlxG.mouse.cursor.active)
				FlxG.mouse.cursor.update();
			if(FlxG.mouse.cursor.visible)
				FlxG.mouse.cursor.render();
		}
		_state.postProcess();
		if(_paused)
			pause.render();
		FlxG.buffer.unlock();
		//Keep track of how long it took to draw everything
		_console.mtrRender.add(Lib.getTimer()-updateMark);
	}
	
	/**
	 * Used to instantiate the guts of flixel once we have a valid pointer to the root.
	 */
	public function create(event:Event):Void
	{
		if(stage == null)
			return;
		var i:Int;
		var soundPrefs:FlxSave;
		
		//Set up the view window and double buffering
		stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        stage.frameRate = _framerate;
        _screen = new Sprite();
        addChild(_screen);
		var tmp:Bitmap = new Bitmap(new BitmapData(FlxG.width,FlxG.height,true,FlxState.bgColor));
		tmp.x = _gameXOffset;
		tmp.y = _gameYOffset;
		tmp.scaleX = tmp.scaleY = _zoom;
		_screen.addChild(tmp);
		FlxG.buffer = tmp.bitmapData;
		
		//Initialize game console
		_console = new FlxConsole(_gameXOffset,_gameYOffset,_zoom);
		addChild(_console);
		var vstring:String = FlxG.LIBRARY_NAME+" v"+FlxG.LIBRARY_MAJOR_VERSION+"."+FlxG.LIBRARY_MINOR_VERSION;
		if(FlxG.debug)
			vstring += " [debug]";
		else
			vstring += " [release]";
		var underline:String = "";
		for (i in 0 ... vstring.length+32)
			underline += "-";
		FlxG.log(vstring);
		FlxG.log(underline);
		
		//Add basic input even listeners
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, FlxG.keys.handleKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, FlxG.mouse.handleMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, FlxG.mouse.handleMouseUp);
		stage.addEventListener(MouseEvent.MOUSE_OUT, FlxG.mouse.handleMouseOut);
		stage.addEventListener(MouseEvent.MOUSE_OVER, FlxG.mouse.handleMouseOver);
						
		//Initialize the pause screen
		stage.addEventListener(Event.DEACTIVATE, onFocusLost);
		stage.addEventListener(Event.ACTIVATE, onFocus);
		
		//Sound Tray popup
		_soundTray = new Sprite();
		_soundTray.visible = false;
		_soundTray.scaleX = 2;
		_soundTray.scaleY = 2;
		tmp = new Bitmap(new BitmapData(80,30,true,0x7F000000));
		_soundTray.x = (_gameXOffset+FlxG.width/2)*_zoom-(tmp.width/2)*_soundTray.scaleX;
		_soundTray.addChild(tmp);
		
		var text:TextField = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;
		#if flash9
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		#end
		text.defaultTextFormat = new TextFormat("system",8,0xffffff,null,null,null,null,null,TextFormatAlign.CENTER);
		_soundTray.addChild(text);
		text.text = "VOLUME";
		text.y = 16;
		
		var bx:Int = 10;
		var by:Int = 14;
		_soundTrayBars = new Array();
		for(i in 0...10)
		{
			tmp = new Bitmap(new BitmapData(4,i+1,false,0xffffff));
			tmp.x = bx;
			tmp.y = by;
			_soundTrayBars.push(_soundTray.addChild(tmp));
			bx += 6;
			by--;
		}
		addChild(_soundTray);

		//Initialize the decorative frame (optional)
		if(_frame != null)
		{
			var bmp:Bitmap = Type.createInstance(_frame, []);
			bmp.scaleX = _zoom;
			bmp.scaleY = _zoom;
			addChild(bmp);
		}
		
		//Check for saved sound preference data
		soundPrefs = new FlxSave();
		if(soundPrefs.bind("flixel") && (soundPrefs.data.sound != null))
		{
			if(soundPrefs.data.volume != null)
				FlxG.volume = soundPrefs.data.volume;
			if(soundPrefs.data.mute != null)
				FlxG.mute = soundPrefs.data.mute;
			showSoundTray(true);
		}
		
		//All set!
		switchState(Type.createInstance(_iState, []));
		FlxState.screen.unsafeBind(FlxG.buffer);
		removeEventListener(Event.ENTER_FRAME, create);
		addEventListener(Event.ENTER_FRAME, update);
	}
}
