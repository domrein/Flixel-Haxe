package org.flixel;

	import org.flixel.data.FlxList;

	/**
	 * A fairly generic quad tree structure for rapid overlap checks.
	 * FlxQuadTree is also configured for single or dual list operation.
	 * You can add items either to its A list or its B list.
	 * When you do an overlap check, you can compare the A list to itself,
	 * or the A list against the B list.  Handy for different things!
	 */
	class FlxQuadTree extends FlxRect {
		/**
		 * Flag for specifying that you want to add an object to the A list.
		 */
		
		/**
		 * Flag for specifying that you want to add an object to the A list.
		 */
		public static var A_LIST:Int = 0;
		/**
		 * Flag for specifying that you want to add an object to the B list.
		 */
		public static var B_LIST:Int = 1;
		
		/**
		 * Whether this branch of the tree can be subdivided or not.
		 */
		var _canSubdivide:Bool;
		
		/**
		 * These variables refer to the internal A and B linked lists,
		 * which are used to store objects in the leaves.
		 */
		var _headA:FlxList;
		var _tailA:FlxList;
		var _headB:FlxList;
		var _tailB:FlxList;

		/**
		 * These variables refer to the potential child quadrants for this node.
		 */
		static var _min:Int;
		var _nw:FlxQuadTree;
		var _ne:FlxQuadTree;
		var _se:FlxQuadTree;
		var _sw:FlxQuadTree;		
		var _l:Float;
		var _r:Float;
		var _t:Float;
		var _b:Float;
		var _hw:Float;
		var _hh:Float;
		var _mx:Float;
		var _my:Float;
		
		/**
		 * These objects are used to reduce recursive parameters internally.
		 */
		static var _o:FlxObject;
		static var _ol:Float;
		static var _ot:Float;
		static var _or:Float;
		static var _ob:Float;
		static var _oa:Int;
		static var _oc:Dynamic;
		
		/**
		 * Instantiate a new Quad Tree node.
		 * 
		 * @param	X			The X-coordinate of the point in space.
		 * @param	Y			The Y-coordinate of the point in space.
		 * @param	Width		Desired width of this node.
		 * @param	Height		Desired height of this node.
		 * @param	Parent		The parent branch or node.  Pass null to create a root.
		 */
		public function new(X:Float, Y:Float, Width:Float, Height:Float, ?Parent:FlxQuadTree=null)
		{
			super(Math.floor(X),Math.floor(Y),Math.floor(Width),Math.floor(Height));
			_headA = _tailA = new FlxList();
			_headB = _tailB = new FlxList();
			
			/*DEBUG: draw a randomly colored rectangle indicating this quadrant (may induce seizures)
			var brush:FlxSprite = new FlxSprite().createGraphic(Width,Height,0xffffffff*FlxU.random());
			FlxState.screen.draw(brush,X+FlxG.scroll.x,Y+FlxG.scroll.y);//*/
			
			//Copy the parent's children (if there are any)
			if(Parent != null)
			{
				var itr:FlxList;
				var ot:FlxList;
				if(Parent._headA.object != null)
				{
					itr = Parent._headA;
					while(itr != null)
					{
						if(_tailA.object != null)
						{
							ot = _tailA;
							_tailA = new FlxList();
							ot.next = _tailA;
						}
						_tailA.object = itr.object;
						itr = itr.next;
					}
				}
				if(Parent._headB.object != null)
				{
					itr = Parent._headB;
					while(itr != null)
					{
						if(_tailB.object != null)
						{
							ot = _tailB;
							_tailB = new FlxList();
							ot.next = _tailB;
						}
						_tailB.object = itr.object;
						itr = itr.next;
					}
				}
			}
			else
				_min = Math.floor((width + height)/(2*FlxU.quadTreeDivisions));
			_canSubdivide = (width > _min) || (height > _min);
			
			//Set up comparison/sort helpers
			_nw = null;
			_ne = null;
			_se = null;
			_sw = null;
			_l = x;
			_r = x+width;
			_hw = width/2;
			_mx = _l+_hw;
			_t = y;
			_b = y+height;
			_hh = height/2;
			_my = _t+_hh;
		}
		
		/**
		 * Call this function to add an object to the root of the tree.
		 * This function will recursively add all group members, but
		 * not the groups themselves.
		 * 
		 * @param	Object		The <code>FlxObject</code> you want to add.  <code>FlxGroup</code> objects will be recursed and their applicable members added automatically.
		 * @param	List		A <code>Int</code> flag indicating the list to which you want to add the objects.  Options are <code>A_LIST</code> and <code>B_LIST</code>.
		 */
		public function add(Object:FlxObject, List:Int):Void
		{
			_oa = List;
			if(Object._group)
			{
				var m:FlxObject;
				var members:Array<FlxObject> = (cast Object).members;
				var l:Int = members.length;
				for(i in 0...l)
				{
					m = cast( members[i], FlxObject);
					if((m != null) && m.exists)
					{
						if(m._group)
							add(m,List);
						else if(m.solid)
						{
							_o = m;
							_ol = _o.x;
							_ot = _o.y;
							_or = _o.x + _o.width;
							_ob = _o.y + _o.height;
							addObject();
						}
					}
				}
			}
			if(Object.solid)
			{
				_o = Object;
				_ol = _o.x;
				_ot = _o.y;
				_or = _o.x + _o.width;
				_ob = _o.y + _o.height;
				addObject();
			}
		}
		
		/**
		 * Internal function for recursively navigating and creating the tree
		 * while adding objects to the appropriate nodes.
		 */
		function addObject():Void
		{
			//If this quad (not its children) lies entirely inside this object, add it here
			if(!_canSubdivide || ((_l >= _ol) && (_r <= _or) && (_t >= _ot) && (_b <= _ob)))
			{
				addToList();
				return;
			}
			
			//See if the selected object fits completely inside any of the quadrants
			if((_ol > _l) && (_or < _mx))
			{
				if((_ot > _t) && (_ob < _my))
				{
					if(_nw == null)
						_nw = new FlxQuadTree(_l,_t,_hw,_hh,this);
					_nw.addObject();
					return;
				}
				if((_ot > _my) && (_ob < _b))
				{
					if(_sw == null)
						_sw = new FlxQuadTree(_l,_my,_hw,_hh,this);
					_sw.addObject();
					return;
				}
			}
			if((_ol > _mx) && (_or < _r))
			{
				if((_ot > _t) && (_ob < _my))
				{
					if(_ne == null)
						_ne = new FlxQuadTree(_mx,_t,_hw,_hh,this);
					_ne.addObject();
					return;
				}
				if((_ot > _my) && (_ob < _b))
				{
					if(_se == null)
						_se = new FlxQuadTree(_mx,_my,_hw,_hh,this);
					_se.addObject();
					return;
				}
			}
			
			//If it wasn't completely contained we have to check out the partial overlaps
			if((_or > _l) && (_ol < _mx) && (_ob > _t) && (_ot < _my))
			{
				if(_nw == null)
					_nw = new FlxQuadTree(_l,_t,_hw,_hh,this);
				_nw.addObject();
			}
			if((_or > _mx) && (_ol < _r) && (_ob > _t) && (_ot < _my))
			{
				if(_ne == null)
					_ne = new FlxQuadTree(_mx,_t,_hw,_hh,this);
				_ne.addObject();
			}
			if((_or > _mx) && (_ol < _r) && (_ob > _my) && (_ot < _b))
			{
				if(_se == null)
					_se = new FlxQuadTree(_mx,_my,_hw,_hh,this);
				_se.addObject();
			}
			if((_or > _l) && (_ol < _mx) && (_ob > _my) && (_ot < _b))
			{
				if(_sw == null)
					_sw = new FlxQuadTree(_l,_my,_hw,_hh,this);
				_sw.addObject();
			}
		}
		
		/**
		 * Internal function for recursively adding objects to leaf lists.
		 */
		function addToList():Void
		{
			var ot:FlxList;
			if(_oa == A_LIST)
			{
				if(_tailA.object != null)
				{
					ot = _tailA;
					_tailA = new FlxList();
					ot.next = _tailA;
				}
				_tailA.object = _o;
			}
			else
			{
				if(_tailB.object != null)
				{
					ot = _tailB;
					_tailB = new FlxList();
					ot.next = _tailB;
				}
				_tailB.object = _o;
			}
			if(!_canSubdivide)
				return;
			if(_nw != null)
				_nw.addToList();
			if(_ne != null)
				_ne.addToList();
			if(_se != null)
				_se.addToList();
			if(_sw != null)
				_sw.addToList();
		}
		
		/**
		 * <code>FlxQuadTree</code>'s other main function.  Call this after adding objects
		 * using <code>FlxQuadTree.add()</code> to compare the objects that you loaded.
		 * 
		 * @param	BothLists	Whether you are doing an A-B list comparison, or comparing A against itself.
		 * @param	Callback	A function with two <code>FlxObject</code> parameters - e.g. <code>myOverlapFunction(Object1:FlxObject,Object2:FlxObject);</code>  If no function is provided, <code>FlxQuadTree</code> will call <code>kill()</code> on both objects.
		 *
		 * @return	Whether or not any overlaps were found.
		 */
		public function overlap(?BothLists:Bool=true,?Callback:Dynamic=null):Bool
		{
			_oc = Callback;
			var c:Bool = false;
			var itr:FlxList;
			if(BothLists)
			{
				//An A-B list comparison
				_oa = B_LIST;
				if(_headA.object != null)
				{
					itr = _headA;
					while(itr != null)
					{
						_o = itr.object;
						if(_o.exists && _o.solid && overlapNode())
							c = true;
						itr = itr.next;
					}
				}
				_oa = A_LIST;
				if(_headB.object != null)
				{
					itr = _headB;
					while(itr != null)
					{
						_o = itr.object;
						if(_o.exists && _o.solid)
						{
							if((_nw != null) && _nw.overlapNode())
								c = true;
							if((_ne != null) && _ne.overlapNode())
								c = true;
							if((_se != null) && _se.overlapNode())
								c = true;
							if((_sw != null) && _sw.overlapNode())
								c = true;
						}
						itr = itr.next;
					}
				}
			}
			else
			{
				//Just checking the A list against itself
				if(_headA.object != null)
				{
					itr = _headA;
					while(itr != null)
					{
						_o = itr.object;
						if(_o.exists && _o.solid && overlapNode(itr.next))
							c = true;
						itr = itr.next;
					}
				}
			}
			
			//Advance through the tree by calling overlap on each child
			if((_nw != null) && _nw.overlap(BothLists,_oc))
				c = true;
			if((_ne != null) && _ne.overlap(BothLists,_oc))
				c = true;
			if((_se != null) && _se.overlap(BothLists,_oc))
				c = true;
			if((_sw != null) && _sw.overlap(BothLists,_oc))
				c = true;
			
			return c;
		}
		
		/**
		 * An internal function for comparing an object against the contents of a node.
		 * 
		 * @param	Iterator	An optional pointer to a linked list entry (for comparing A against itself).
		 * 
		 * @return	Whether or not any overlaps were found.
		 */
		function overlapNode(?Iterator:FlxList=null):Bool
		{
			//member list setup
			var c:Bool = false;
			var co:FlxObject;
			var itr:FlxList = Iterator;
			if(itr == null)
			{
				if(_oa == A_LIST)
					itr = _headA;
				else
					itr = _headB;
			}
			
			//Make sure this is a valid list to walk first!
			if(itr.object != null)
			{
				//Walk the list and check for overlaps
				while(itr != null)
				{
					co = itr.object;
					if( (_o == co) || !co.exists || !_o.exists || !co.solid || !_o.solid ||
						(_o.x + _o.width  < co.x + FlxU.roundingError) ||
						(_o.x + FlxU.roundingError > co.x + co.width) ||
						(_o.y + _o.height < co.y + FlxU.roundingError) ||
						(_o.y + FlxU.roundingError > co.y + co.height) )
					{
						itr = itr.next;
						continue;
					}
					if(_oc == null)
					{
						_o.kill();
						co.kill();
						c = true;
					}
					else if(_oc(_o,co))
						c = true;
					itr = itr.next;
				}
			}
			
			return c;
		}
	}
