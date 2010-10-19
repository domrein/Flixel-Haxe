package org.flixel.data;

	import org.flixel.FlxG;
	
	/**
	 * This is a special effects utility class to help FlxGame do the 'quake' or screenshake effect.
	 */
	class FlxQuake
	 {
		/**
		 * The game's level of zoom.
		 */
		
		/**
		 * The game's level of zoom.
		 */
		var _zoom:Int;
		/**
		 * The intensity of the quake effect: a percentage of the screen's size.
		 */
		var _intensity:Float;
		/**
		 * Set to countdown the quake time.
		 */
		var _timer:Float;
		
		/**
		 * The amount of X distortion to apply to the screen.
		 */
		public var x:Int;
		/**
		 * The amount of Y distortion to apply to the screen.
		 */
		public var y:Int;
		
		/**
		 * Constructor.
		 */
		public function new(Zoom:Int)
		{
			_zoom = Zoom;
			start(0);
		}
		
		/**
		 * Reset and trigger this special effect.
		 * 
		 * @param	Intensity	Percentage of screen size representing the maximum distance that the screen can move during the 'quake'.
		 * @param	Duration	The length in seconds that the "quake" should last.
		 */
		public function start(Intensity:Float=0.05,Duration:Float=0.5):Void
		{
			stop();
			_intensity = Intensity;
			_timer = Duration;
		}
		
		/**
		 * Stops this screen effect.
		 */
		public function stop():Void
		{
			x = 0;
			y = 0;
			_intensity = 0;
			_timer = 0;
		}
		
		/**
		 * Updates and/or animates this special effect.
		 */
		public function update():Void
		{
			if(_timer > 0)
			{
				_timer -= FlxG.elapsed;
				if(_timer <= 0)
				{
					_timer = 0;
					x = 0;
					y = 0;
				}
				else
				{
					x = Math.floor((Math.random()*_intensity*FlxG.width*2-_intensity*FlxG.width)*_zoom);
					y = Math.floor((Math.random()*_intensity*FlxG.height*2-_intensity*FlxG.height)*_zoom);
				}
			}
		}
	}
