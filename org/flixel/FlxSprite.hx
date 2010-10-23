package org.flixel;

	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.flixel.data.FlxAnim;
import flash.display.Bitmap;
	
	#if flash9
	import flash.display.BlendMode;
	#end
	
	/**
	* The main "game object" class, handles basic physics and animation.
	*/
	class FlxSprite extends FlxObject {
		/**
		 * Useful for controlling flipped animations and checking player orientation.
		 */
		
		public var alpha(getAlpha, setAlpha) : Float;
		public var color(getColor, setColor) : Int;
		public var facing(getFacing, setFacing) : Int;
		override public var fixed(getFixed, setFixed) : Bool;
		public var frame(getFrame, setFrame) : Int;
		public var pixels(getPixels, setPixels) : BitmapData;
		override public var solid(getSolid, setSolid) : Bool;
		/**
		 * Useful for controlling flipped animations and checking player orientation.
		 */
		public static var LEFT:Int = 0;
		/**
		 * Useful for controlling flipped animations and checking player orientation.
		 */
		public static var RIGHT:Int = 1;
		/**
		 * Useful for checking player orientation.
		 */
		public static var UP:Int = 2;
		/**
		 * Useful for checking player orientation.
		 */
		public static var DOWN:Int = 3;
		 
		/**
		* If you changed the size of your sprite object to shrink the bounding box,
		* you might need to offset the new bounding box from the top-left corner of the sprite.
		*/
		public var offset:FlxPoint;
		
		/**
		 * Change the size of your sprite's graphic.
		 * NOTE: Scale doesn't currently affect collisions automatically,
		 * you will need to adjust the width, height and offset manually.
		 * WARNING: scaling sprites decreases rendering performance for this sprite by a factor of 10x!
		 */
		public var scale:FlxPoint;
		/**
		 * Blending modes, just like Photoshop!
		 * E.g. "multiply", "screen", etc.
		 * @default null
		 */
		public var blend:String;
		/**
		 * Controls whether the object is smoothed when rotated, affects performance.
		 * @default false
		 */
		public var antialiasing:Bool;
		/**
		 * Whether the current animation has finished its first (or only) loop.
		 */
		public var finished:Bool;
		/**
		 * The width of the actual graphic or image being displayed (not necessarily the game object/bounding box).
		 * NOTE: Edit at your own risk!!  This is intended to be read-only.
		 */
		public var frameWidth:Int;
		/**
		 * The height of the actual graphic or image being displayed (not necessarily the game object/bounding box).
		 * NOTE: Edit at your own risk!!  This is intended to be read-only.
		 */
		public var frameHeight:Int;
		
		//Animation helpers
		var _animations:Array<Dynamic>;
		var _flipped:Int;
		var _curAnim:FlxAnim;
		var _curFrame:Int;
		var _caf:Int;
		var _frameTimer:Float;
		var _callback:Dynamic;
		var _facing:Int;
		var _bakedRotation:Float;
		
		//Various rendering helpers
		var _flashRect:Rectangle;
		var _flashRect2:Rectangle;
		var _flashPointZero:Point;
		var _pixels:BitmapData;
		var _framePixels:BitmapData;
		var _alpha:Float;
		var _color:Int;
		var _ct:ColorTransform;
		var _mtx:Matrix;
		var _bbb:BitmapData;
		
		/**
		 * Creates a white 8x8 square <code>FlxSprite</code> at the specified position.
		 * Optionally can load a simple, one-frame graphic instead.
		 * 
		 * @param	X				The initial X position of the sprite.
		 * @param	Y				The initial Y position of the sprite.
		 * @param	SimpleGraphic	The graphic you want to display (OPTIONAL - for simple stuff only, do NOT use for animated images!).
		 */
		public function new(?X:Float=0,?Y:Float=0,?SimpleGraphic:Class<Dynamic>=null)
		{
			super();
			x = X;
			y = Y;

			_flashRect = new Rectangle();
			_flashRect2 = new Rectangle();
			_flashPointZero = new Point();
			offset = new FlxPoint();
			
			scale = new FlxPoint(1,1);
			_alpha = 1;
			_color = 0x00ffffff;
			blend = null;
			antialiasing = false;
			
			finished = false;
			_facing = RIGHT;
			_animations = new Array();
			_flipped = 0;
			_curAnim = null;
			_curFrame = 0;
			_caf = 0;
			_frameTimer = 0;

			_mtx = new Matrix();
			_callback = null;
			
			if(SimpleGraphic == null)
				createGraphic(8,8);
			else
				loadGraphic(SimpleGraphic);
		}
		
		/**
		 * Load an image from an embedded graphic file.
		 * 
		 * @param	Graphic		The image you want to use.
		 * @param	Animated	Whether the Graphic parameter is a single sprite or a row of sprites.
		 * @param	Reverse		Whether you need this class to generate horizontally flipped versions of the animation frames.
		 * @param	Width		OPTIONAL - Specify the width of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
		 * @param	Height		OPTIONAL - Specify the height of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
		 * @param	Unique		Whether the graphic should be a unique instance in the graphics cache.
		 * 
		 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadGraphic(Graphic:Class<Dynamic>,?Animated:Bool=false,?Reverse:Bool=false,?Width:Int=0,?Height:Int=0,?Unique:Bool=false):FlxSprite
		{
			_bakedRotation = 0;
			_pixels = FlxG.addBitmap(Graphic,Reverse,Unique);
			//TEMP NOTE: bitmap loads correctly up to this point at least
			
			if(Reverse)
				_flipped = _pixels.width>>1;
			else
				_flipped = 0;
			if(Width == 0)
			{
				if(Animated)
					Width = _pixels.height;
				else if(_flipped > 0)
					Width = Math.floor(_pixels.width/2);
				else
					Width = Math.floor(_pixels.width);
			}
			width = frameWidth = Width;
			if(Height == 0)
			{
				if(Animated)
					Height = Math.floor(width);
				else
					Height = Math.floor(_pixels.height);
			}
			height = frameHeight = Height;
			resetHelpers();
			return this;
		}
		
		/**
		 * Create a pre-rotated sprite sheet from a simple sprite.
		 * This can make a huge difference in graphical performance!
		 * 
		 * @param	Graphic			The image you want to rotate & stamp.
		 * @param	Frames			The number of frames you want to use (more == smoother rotations).
		 * @param	Offset			Use this to select a specific frame to draw from the graphic.
		 * @param	AntiAliasing	Whether to use high quality rotations when creating the graphic.
		 * @param	AutoBuffer		Whether to automatically increase the image size to accomodate rotated corners.
		 * 
		 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadRotatedGraphic(Graphic:Class<Dynamic>, ?Rotations:Int=16, ?Frame:Int=-1, ?AntiAliasing:Bool=false, ?AutoBuffer:Bool=false):FlxSprite
		{
			//Create the brush and canvas
			var rows:Int = Math.floor(Math.sqrt(Rotations));
			var brush:BitmapData = FlxG.addBitmap(Graphic);
			if(Frame >= 0)
			{
				//Using just a segment of the graphic - find the right bit here
				var full:BitmapData = brush;
				brush = new BitmapData(full.height,full.height);
				var rx:Int = Frame*brush.width;
				var ry:Int = 0;
				var fw:Int = full.width;
				if(rx >= fw)
				{
					ry = Math.floor(rx/fw)*brush.height;
					rx %= fw;
				}
				_flashRect.x = rx;
				_flashRect.y = ry;
				_flashRect.width = brush.width;
				_flashRect.height = brush.height;
				brush.copyPixels(full,_flashRect,_flashPointZero);
			}
			
			var max:Int = brush.width;
			if(brush.height > max)
				max = brush.height;
			if(AutoBuffer)
				max = Math.floor(max * 1.5);
			var cols:Int = Math.floor(FlxU.ceil(Rotations/rows));
			width = max*cols;
			height = max*rows;
			var key:String = Type.getClassName(Graphic) + ":" + Frame + ":" + width + "x" + height;
			var skipGen:Bool = FlxG.checkBitmapCache(key);
			_pixels = FlxG.createBitmap(Math.floor(width), Math.floor(height), 0, true, key);
			width = frameWidth = _pixels.width;
			height = frameHeight = _pixels.height;
			_bakedRotation = 360/Rotations;
			
			//Generate a new sheet if necessary, then fix up the width & height
			if(!skipGen)
			{
				var r:Int;
				var c:Int;
				var ba:Float = 0;
				var bw2:Int = Math.floor(brush.width/2);
				var bh2:Int = Math.floor(brush.height/2);
				var gxc:Int = Math.floor(max/2);
				var gyc:Int = Math.floor(max/2);
				for(r in 0...rows)
				{
					for(c in 0...cols)
					{
						_mtx.identity();
						_mtx.translate(-bw2,-bh2);
						_mtx.rotate(Math.PI * 2 * (ba / 360));
						_mtx.translate(max*c+gxc, gyc);
						ba += _bakedRotation;
						_pixels.draw(brush,_mtx,null,null,null,AntiAliasing);
					}
					gyc += max;
				}
			}
			width = height = frameWidth = frameHeight = max;
			resetHelpers();
			return this;
		}
		
		/**
		 * This function creates a flat colored square image dynamically.
		 * 
		 * @param	Width		The width of the sprite you want to generate.
		 * @param	Height		The height of the sprite you want to generate.
		 * @param	Color		Specifies the color of the generated block.
		 * @param	Unique		Whether the graphic should be a unique instance in the graphics cache.
		 * @param	Key			Optional parameter - specify a string key to identify this graphic in the cache.  Trumps Unique flag.
		 * 
		 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
		 */
		public function createGraphic(Width:Int,Height:Int,?Color:Int=0xffffffff,?Unique:Bool=false,?Key:String=null):FlxSprite
		{
			_bakedRotation = 0;
			_pixels = FlxG.createBitmap(Width,Height,Color,Unique,Key);
			width = frameWidth = _pixels.width;
			height = frameHeight = _pixels.height;
			resetHelpers();
			return this;
		}
		
		/**
		 * Set <code>pixels</code> to any <code>BitmapData</code> object.
		 * Automatically adjust graphic size and render helpers.
		 */
		public function getPixels():BitmapData{
			return _pixels;
		}
		
		/**
		 * @private
		 */
		public function setPixels(Pixels:BitmapData):BitmapData{
			_pixels = Pixels;
			width = frameWidth = _pixels.width;
			height = frameHeight = _pixels.height;
			resetHelpers();
			return Pixels;
		}
		
		/**
		 * Resets some important variables for sprite optimization and rendering.
		 */

		function resetHelpers():Void
		{
			_flashRect.x = 0;
			_flashRect.y = 0;
			_flashRect.width = frameWidth;
			_flashRect.height = frameHeight;
			_flashRect2.x = 0;
			_flashRect2.y = 0;
			_flashRect2.width = _pixels.width;
			_flashRect2.height = _pixels.height;
			if((_framePixels == null) || (_framePixels.width != width) || (_framePixels.height != height))
				_framePixels = new BitmapData(Math.floor(width), Math.floor(height), true, 0x00FFFFFF);
			if((_bbb == null) || (_bbb.width != width) || (_bbb.height != height))
				_bbb = new BitmapData(Math.floor(width), Math.floor(height));
			origin.x = frameWidth/2;
			origin.y = frameHeight/2;
			//DEBUG!!!
			//flash.Lib.current.addChild(new Bitmap(_pixels));
			_framePixels.copyPixels(_pixels,_flashRect,_flashPointZero);
			//if (forAlien)
			//	flash.Lib.current.addChild(new Bitmap(_framePixels));
			if(FlxG.showBounds)
				drawBounds();
			_caf = 0;
			refreshHulls();
		}
		
		public override function getSolid():Bool {
			return super.getSolid();
		}
		
		/**
		 * @private
		 */
		public override function setSolid(Solid:Bool):Bool{
			var os:Bool = _solid;
			_solid = Solid;
			if((os != _solid) && FlxG.showBounds)
				calcFrame();
			return Solid;
		}
		
		public override function getFixed():Bool {
			return super.getFixed();
		}
		
		/**
		 * @private
		 */
		public override function setFixed(Fixed:Bool):Bool{
			var of:Bool = _fixed;
			_fixed = Fixed;
			if((of != _fixed) && FlxG.showBounds)
				calcFrame();
			return Fixed;
		}
		
		/**
		 * Set <code>facing</code> using <code>FlxSprite.LEFT</code>,<code>RIGHT</code>,
		 * <code>UP</code>, and <code>DOWN</code> to take advantage of
		 * flipped sprites and/or just track player orientation more easily.
		 */
		public function getFacing():Int{
			return _facing;
		}
		
		/**
		 * @private
		 */
		public function setFacing(Direction:Int):Int{
			var c:Bool = _facing != Direction;
			_facing = Direction;
			if(c) calcFrame();
			return Direction;
		}
		
		/**
		 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the sprite.
		 */
		public function getAlpha():Float{
			return _alpha;
		}
		
		/**
		 * @private
		 */
		public function setAlpha(Alpha:Float):Float{
			if(Alpha > 1) Alpha = 1;
			if(Alpha < 0) Alpha = 0;
			if(Alpha == _alpha) return Alpha;
			_alpha = Alpha;
			if((_alpha != 1) || (_color != 0x00ffffff)) _ct = new ColorTransform((_color>>16)/255.0,(_color>>8&0xff)/255.0,(_color&0xff)/255.0,_alpha);
			else _ct = null;
			calcFrame();
			return Alpha;
		}
		
		/**
		 * Set <code>color</code> to a number in this format: 0xRRGGBB.
		 * <code>color</code> IGNORES ALPHA.  To change the opacity use <code>alpha</code>.
		 * Tints the whole sprite to be this color (similar to OpenGL vertex colors).
		 */
		public function getColor():Int{
			return _color;
		}
		
		/**
		 * @private
		 */
		public function setColor(Color:Int):Int{
			Color &= 0x00ffffff;
			if(_color == Color) return Color;
			_color = Color;
			if((_alpha != 1) || (_color != 0x00ffffff)) _ct = new ColorTransform((_color>>16)/255.0,(_color>>8&0xff)/255.0,(_color&0xff)/255.0,_alpha);
			else _ct = null;
			calcFrame();
			return Color;
		}
		

		/**
		 * This function draws or stamps one <code>FlxSprite</code> onto another.
		 * This function is NOT intended to replace <code>render()</code>!
		 * 
		 * @param	Brush		The image you want to use as a brush or stamp or pen or whatever.
		 * @param	X			The X coordinate of the brush's top left corner on this sprite.
		 * @param	Y			They Y coordinate of the brush's top left corner on this sprite.
		 */
		public function draw(Brush:FlxSprite,?X:Int=0,?Y:Int=0):Void
		{
			var b:BitmapData = Brush._framePixels;
			
			//Simple draw
			if(((Brush.angle == 0) || (Brush._bakedRotation > 0)) && (Brush.scale.x == 1) && (Brush.scale.y == 1) && (Brush.blend == null))
			{
				_flashPoint.x = X;
				_flashPoint.y = Y;
				_flashRect2.width = b.width;
				_flashRect2.height = b.height;
				_pixels.copyPixels(b,_flashRect2,_flashPoint,null,null,true);
				_flashRect2.width = _pixels.width;
				_flashRect2.height = _pixels.height;
				calcFrame();
				return;
			}

			//Advanced draw
			_mtx.identity();
			_mtx.translate(-Brush.origin.x,-Brush.origin.y);
			_mtx.scale(Brush.scale.x,Brush.scale.y);
			if(Brush.angle != 0) _mtx.rotate(Math.PI * 2 * (Brush.angle / 360));
			_mtx.translate(X+Brush.origin.x,Y+Brush.origin.y);
			#if flash9
			var brushBlend:BlendMode = cast(Brush.blend, BlendMode);
			#else
			var brushBlend:String = Brush.blend;
			#end
			_pixels.draw(b, _mtx, null, brushBlend, null, Brush.antialiasing);
			calcFrame();
		}
		
		/**
		 * Fills this sprite's graphic with a specific color.
		 * 
		 * @param	Color		The color with which to fill the graphic, format 0xAARRGGBB.
		 */
		public function fill(Color:Int):Void
		{
			_pixels.fillRect(_flashRect2,Color);
			if(_pixels != _framePixels)
				calcFrame();
		}
		
		/**
		 * Internal function for updating the sprite's animation.
		 * Useful for cases when you need to update this but are buried down in too many supers.
		 * This function is called automatically by <code>FlxSprite.update()</code>.
		 */
		function updateAnimation():Void
		{
			if(_bakedRotation != 0)
			{
				var oc:Int = _caf;
				var ta:Int = Math.floor(angle%360);
				if(ta < 0)
					ta += 360;
				_caf = Math.floor(ta/_bakedRotation);
				if(oc != _caf)
					calcFrame();
				return;
			}
			if((_curAnim != null) && (_curAnim.delay > 0) && (_curAnim.looped || !finished))
			{
				_frameTimer += FlxG.elapsed;
				if(_frameTimer > _curAnim.delay)
				{
					_frameTimer -= _curAnim.delay;
					if(_curFrame == _curAnim.frames.length-1)
					{
						if(_curAnim.looped) _curFrame = 0;
						finished = true;
					}
					else
						_curFrame++;
					_caf = _curAnim.frames[_curFrame];
					calcFrame();
				}
			}
		}
		
		/**
		 * Main game loop update function.  Override this to create your own sprite logic!
		 * Just don't forget to call super.update() or any of the helper functions.
		 */
		public override function update():Void
		{
			updateMotion();
			updateAnimation();
			updateFlickering();
		}
		
		/**
		 * Internal function that performs the actual sprite rendering, called by render().
		 */
		function renderSprite():Void
		{
			if(FlxObject._refreshBounds)
				calcFrame();
			
			getScreenXY(_point);
			_flashPoint.x = _point.x;
			_flashPoint.y = _point.y;
			
			//Simple render
			if(((angle == 0) || (_bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1) && (blend == null))
			{
				//DEBUG!
				//flash.Lib.current.addChild(new Bitmap(_framePixels));
				FlxG.buffer.copyPixels(_framePixels,_flashRect,_flashPoint,null,null,true);
				return;
			}
			
			//Advanced render
			_mtx.identity();
			_mtx.translate(-origin.x,-origin.y);
			_mtx.scale(scale.x,scale.y);
			if(angle != 0) _mtx.rotate(Math.PI * 2 * (angle / 360));
			_mtx.translate(_point.x+origin.x,_point.y+origin.y);
			#if flash9
			var blendMode:BlendMode = cast(blend, BlendMode);
			#else
			var blendMode:String = blend;
			#end
			FlxG.buffer.draw(_framePixels,_mtx,null,blendMode,null,antialiasing);
		}
		
		/**
		 * Called by game loop, updates then blits or renders current frame of animation to the screen
		 */
		public override function render():Void
		{
			renderSprite();
		}
		
		/**
		 * Checks to see if a point in 2D space overlaps this FlxCore object.
		 * 
		 * @param	X			The X coordinate of the point.
		 * @param	Y			The Y coordinate of the point.
		 * @param	PerPixel	Whether or not to use per pixel collision checking.
		 * 
		 * @return	Whether or not the point overlaps this object.
		 */
		public override function overlapsPoint(X:Float,Y:Float,?PerPixel:Bool = false):Bool
		{
			X -= FlxU.floor(FlxG.scroll.x);
			Y -= FlxU.floor(FlxG.scroll.y);
			getScreenXY(_point);
			if(PerPixel) {  //TODO: get PerPixel working in cpp
				#if flash9
				return _framePixels.hitTest(new Point(0,0),0xFF,new Point(X-_point.x,Y-_point.y));
				#else
				return true;
				#end
			}
			else if((X <= _point.x) || (X >= _point.x+frameWidth) || (Y <= _point.y) || (Y >= _point.y+frameHeight)) {
				return false;
			}
			return true;
		}
		
		/**
		 * Triggered whenever this sprite is launched by a <code>FlxEmitter</code>.
		 */
		public function onEmit():Void { }
		
		/**
		 * Adds a new animation to the sprite.
		 * 
		 * @param	Name		What this animation should be called (e.g. "run").
		 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
		 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40 fps).
		 * @param	Looped		Whether or not the animation is looped or just plays once.
		 */
		public function addAnimation(Name:String, Frames:Array<Dynamic>, ?FrameRate:Float=0, ?Looped:Bool=true):Void
		{
			_animations.push(new FlxAnim(Name,Frames,FrameRate,Looped));
		}
		
		/**
		 * Pass in a function to be called whenever this sprite's animation changes.
		 * 
		 * @param	AnimationCallback		A function that has 3 parameters: a string name, a Int frame number, and a Int frame index.
		 */
		public function addAnimationCallback(AnimationCallback:Dynamic):Void
		{
			_callback = AnimationCallback;
		}
		
		/**
		 * Plays an existing animation (e.g. "run").
		 * If you call an animation that is already playing it will be ignored.
		 * 
		 * @param	AnimName	The string name of the animation you want to play.
		 * @param	Force		Whether to force the animation to restart.
		 */
		public function play(AnimName:String,?Force:Bool=false):Void
		{
			if(!Force && (_curAnim != null) && (AnimName == _curAnim.name)) return;
			_curFrame = 0;
			_caf = 0;
			_frameTimer = 0;
			var al:Int = _animations.length;
			for(i in 0...al)
			{
				if(_animations[i].name == AnimName)
				{
					_curAnim = _animations[i];
					if(_curAnim.delay <= 0)
						finished = true;
					else
						finished = false;
					_caf = _curAnim.frames[_curFrame];
					calcFrame();
					return;
				}
			}
		}

		/**
		 * Tell the sprite to change to a random frame of animation
		 * Useful for instantiating particles or other weird things.
		 */
		public function randomFrame():Void
		{
			_curAnim = null;
			_caf = Math.floor(FlxU.random()*(_pixels.width/frameWidth));
			calcFrame();
		}
		
		/**
		 * Tell the sprite to change to a specific frame of animation.
		 * 
		 * @param	Frame	The frame you want to display.
		 */
		public function getFrame():Int{
			return _caf;
		}
		
		/**
		 * @private
		 */
		public function setFrame(Frame:Int):Int{
			_curAnim = null;
			_caf = Frame;
			calcFrame();
			return Frame;
		}
		
		/**
		 * Call this function to figure out the on-screen position of the object.
		 * 
		 * @param	P	Takes a <code>Point</code> object and assigns the post-scrolled X and Y values of this object to it.
		 * 
		 * @return	The <code>Point</code> you passed in, or a new <code>Point</code> if you didn't pass one, containing the screen X and Y position of this object.
		 */
		public override function getScreenXY(?Point:FlxPoint=null):FlxPoint
		{
			if(Point == null) Point = new FlxPoint();
			Point.x = FlxU.floor(x + FlxU.roundingError)+FlxU.floor(FlxG.scroll.x*scrollFactor.x) - offset.x;
			Point.y = FlxU.floor(y + FlxU.roundingError)+FlxU.floor(FlxG.scroll.y*scrollFactor.y) - offset.y;
			return Point;
		}
		
		/**
		 * Internal function to update the current animation frame.
		 */
		function calcFrame():Void
		{
			var rx:Int = _caf*frameWidth;
			var ry:Int = 0;

			//Handle sprite sheets
			var w:Int;
			if (_flipped != 0)
				w = _flipped;
			else
				w = _pixels.width;
			if(rx >= w)
			{
				ry = Math.floor(rx/w)*frameHeight;
				rx %= w;
			}
			
			//handle reversed sprites
			if(_flipped != 0 && (_facing == LEFT))
				rx = (_flipped<<1)-rx-frameWidth;
			
			//Update display bitmap
			_flashRect.x = rx;
			_flashRect.y = ry;
			//TODO: right now _framePixels needs to be cleared each frame because it isn't copying alpha pixels correctly
			_framePixels.fillRect(new Rectangle(0, 0, _framePixels.width, _framePixels.height), 0x00FFFFFF);
			_framePixels.copyPixels(_pixels,_flashRect,_flashPointZero);
			_flashRect.x = _flashRect.y = 0;
			#if flash9  //TODO: get color transform working in cpp
			if(_ct != null) _framePixels.colorTransform(_flashRect,_ct);
			#else
			#end
			if(FlxG.showBounds)
				drawBounds();
			if(_callback != null) _callback(_curAnim.name,_curFrame,_caf);
		}
		
		function drawBounds():Void
		{
			var bbbc:Int = getBoundingColor();
			_bbb.fillRect(_flashRect,0);
			var ofrw:Int = Math.floor(_flashRect.width);
			var ofrh:Int = Math.floor(_flashRect.height);
			_flashRect.width = width;
			_flashRect.height = height;
			_flashRect.x = Math.floor(offset.x);
			_flashRect.y = Math.floor(offset.y);
			_bbb.fillRect(_flashRect,bbbc);
			_flashRect.width -= 2;
			_flashRect.height -= 2;
			_flashRect.x++;
			_flashRect.y++;
			_bbb.fillRect(_flashRect,0);
			_flashRect.width = ofrw;
			_flashRect.height = ofrh;
			_flashRect.x = _flashRect.y = 0;
			_framePixels.copyPixels(_bbb,_flashRect,_flashPointZero,null,null,true);
		}
		
		/**
		 * Internal function, currently only used to quickly update FlxState.screen for post-processing.
		 * Potentially super-unsafe, since it doesn't call <code>resetHelpers()</code>!
		 * 
		 * @param	Pixels		The <code>BitmapData</code> object you want to point at.
		 */
		public function unsafeBind(Pixels:BitmapData):Void
		{
			_pixels = _framePixels = Pixels;
		}
	}
