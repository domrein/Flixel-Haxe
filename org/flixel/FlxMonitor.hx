package org.flixel;

	/**
	 * FlxMonitor is a simple class that aggregates and averages data.
	 * Flixel uses this to display the framerate and profiling data
	 * in the developer console.  It's nice for keeping track of
	 * things that might be changing too fast from frame to frame.
	 */
	class FlxMonitor
	 {
		/**
		 * Stores the requested size of the monitor array.
		 */
		
		/**
		 * Stores the requested size of the monitor array.
		 */
		var _size:Int;
		/**
		 * Keeps track of where we are in the array.
		 */
		var _itr:Int;
		/**
		 * An array to hold all the data we are averaging.
		 */
		var _data:Array<Float>;
		
		/**
		 * Creates the monitor array and sets the size.
		 * 
		 * @param	Size	The desired size - more entries means a longer window of averaging.
		 * @param	Default	The default value of the entries in the array (0 by default).
		 */
		public function new(Size:Int,?Default:Int=0)
		{
			_size = Size;
			if(_size <= 0)
				_size = 1;
			_itr = 0;
			_data = new Array();
			for (i in 0 ... _size)
				_data.push(Default);
		}
		
		/**
		 * Adds an entry to the array of data.
		 * 
		 * @param	Data	The value you want to track and average.
		 */
		public function add(Data:Float):Void
		{
			_data[_itr++] = Data;
			if(_itr >= _size)
				_itr = 0;
		}
		
		/**
		 * Averages the value of all the numbers in the monitor window.
		 * 
		 * @return	The average value of all the numbers in the monitor window.
		 */
		public function average():Float
		{
			var sum:Int = 0;
			for (i in 0 ... _size)
				sum += Math.floor(_data[i]);
			return sum/_size;
		}
	}
