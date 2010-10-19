package org.flixel;

	#if flash9
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	#else
	#end
	
	/**
	 * A class to help automate and simplify save game functionality.
	 */
	class FlxSave  {
		/**
		 * Allows you to directly access the data container in the local shared object.
		 * @default null
		 */
		
		/**
		 * Allows you to directly access the data container in the local shared object.
		 * @default null
		 */
		public var data:Dynamic;
		/**
		 * The name of the local shared object.
		 * @default null
		 */
		public var name:String;
		/**
		 * The local shared object itself.
		 * @default null
		 */
		#if flash9
		var _so:SharedObject;
		#else
		var _so:Dynamic;
		#end
		
		/**
		 * Blanks out the containers.
		 */
		public function new()
		{
			name = null;
			_so = null;
			data = null;
		}
		
		/**
		 * Automatically creates or reconnects to locally saved data.
		 * 
		 * @param	Name	The name of the object (should be the same each time to access old data).
		 * 
		 * @return	Whether or not you successfully connected to the save data.
		 */
		public function bind(Name:String):Bool
		{
			name = null;
			_so = null;
			data = null;
			name = Name;
			try
			{
				#if flash9
				_so = SharedObject.getLocal(name);
				#else
				return false;
				#end
			}
			catch(e:Dynamic)
			{
				FlxG.log("WARNING: There was a problem binding to\nthe shared object data from FlxSave.");
				name = null;
				_so = null;
				data = null;
				return false;
			}
			data = _so.data;
			return true;
		}
		
		/**
		 * If you don't like to access the data object directly, you can use this to write to it.
		 * 
		 * @param	FieldName		The name of the data field you want to create or overwrite.
		 * @param	FieldValue		The data you want to store.
		 * @param	MinFileSize		If you need X amount of space for your save, specify it here.
		 * 
		 * @return	Whether or not the write and flush were successful.
		 */
		public function write(FieldName:String,FieldValue:Dynamic,?MinFileSize:Int=0):Bool
		{
			if(_so == null)
			{
				FlxG.log("WARNING: You must call FlxSave.bind()\nbefore calling FlxSave.write().");
				return false;
			}
			Reflect.setField(data, FieldName, FieldValue);
			return forceSave(MinFileSize);
		}
		
		/**
		 * If you don't like to access the data object directly, you can use this to read from it.
		 * 
		 * @param	FieldName		The name of the data field you want to read
		 * 
		 * @return	The value of the data field you are reading (null if it doesn't exist).
		 */
		public function read(FieldName:String):Dynamic
		{
			if(_so == null)
			{
				FlxG.log("WARNING: You must call FlxSave.bind()\nbefore calling FlxSave.read().");
				return null;
			}
			return Reflect.field(data, FieldName);
		}
		
		/**
		 * Writes the local shared object to disk immediately.
		 *
		 * @param	MinFileSize		If you need X amount of space for your save, specify it here.
		 *
		 * @return	Whether or not the flush was successful.
		 */
		public function forceSave(?MinFileSize:Int=0):Bool
		{
			if(_so == null)
			{
				FlxG.log("WARNING: You must call FlxSave.bind()\nbefore calling FlxSave.forceSave().");
				return false;
			}
			var status:Dynamic = null;
			try
			{
				#if flash9
				status = _so.flush(MinFileSize);
				#else
				return false;
				#end
			}
			catch (e:Dynamic)
			{
				FlxG.log("WARNING: There was a problem flushing\nthe shared object data from FlxSave.");
				return false;
			}
			#if flash9
			return status == SharedObjectFlushStatus.FLUSHED;
			#else
			return false;
			#end
		}
		
		/**
		 * Erases everything stored in the local shared object.
		 * 
		 * @param	MinFileSize		If you need X amount of space for your save, specify it here.
		 * 
		 * @return	Whether or not the clear and flush was successful.
		 */
		public function erase(?MinFileSize:Int=0):Bool
		{
			if(_so == null)
			{
				FlxG.log("WARNING: You must call FlxSave.bind()\nbefore calling FlxSave.erase().");
				return false;
			}
			_so.clear();
			return forceSave(MinFileSize);
		}
	}
