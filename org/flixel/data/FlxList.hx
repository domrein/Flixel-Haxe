package org.flixel.data;

	import org.flixel.FlxObject;
	
	/**
	 * The world's smallest linked list class.
	 * Useful for optimizing time-critical or highly repetitive tasks!
	 * See <code>FlxQuadTree</code> for how to use it, IF YOU DARE.
	 */
	class FlxList
	 {
		/**
		 * Stores a reference to a <code>FlxObject</code>.
		 */
		
		/**
		 * Stores a reference to a <code>FlxObject</code>.
		 */
		public var object:FlxObject;
		/**
		 * Stores a reference to the next link in the list.
		 */
		public var next:FlxList;
		
		/**
		 * Creates a new link, and sets <code>object</code> and <code>next</code> to <code>null</null>.
		 */
		public function new()
		{
			object = null;
			next = null;
		}
	}
