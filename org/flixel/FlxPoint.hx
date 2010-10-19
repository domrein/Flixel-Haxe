package org.flixel;

	/**
	 * Stores a 2D floating point coordinate.
	 */
	class FlxPoint
	 {
		/**
		 * @default 0
		 */
		
		/**
		 * @default 0
		 */
		public var x:Float;
		/**
		 * @default 0
		 */
		public var y:Float;
		
		/**
		 * Instantiate a new point object.
		 * 
		 * @param	X		The X-coordinate of the point in space.
		 * @param	Y		The Y-coordinate of the point in space.
		 */
		public function new(?X:Int=0, ?Y:Int=0)
		{
			x = X;
			y = Y;
		}
		
		/**
		 * Convert object to readable string name.  Useful for debugging, save games, etc.
		 */
		public function toString():String
		{
			return FlxU.getClassName(this,true);
		}
	}
