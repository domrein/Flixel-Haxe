package org.flixel.data;

	import flash.display.Bitmap;

	import org.flixel.FlxGroup;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;

	/**
	 * This is the default flixel pause screen.
	 * It can be overridden with your own <code>FlxLayer</code> object.
	 */
	class FlxPause extends FlxGroup {
		
		/*[Embed(source="key_minus.png")]*/ var ImgKeyMinus:Class<Bitmap>;
		/*[Embed(source="key_plus.png")]*/ var ImgKeyPlus:Class<Bitmap>;
		/*[Embed(source="key_0.png")]*/ var ImgKey0:Class<Bitmap>;
		/*[Embed(source="key_p.png")]*/ var ImgKeyP:Class<Bitmap>;

		/**
		 * Constructor.
		 */
		public function new()
		{
			super();
			scrollFactor.x = 0;
			scrollFactor.y = 0;
			var w:Int = 80;
			var h:Int = 92;
			x = (FlxG.width-w)/2;
			y = (FlxG.height-h)/2;
			add((new FlxSprite()).createGraphic(w,h,0xaa000000,true),true);			
			(cast( add(new FlxText(0,0,w,"this game is"),true), FlxText)).alignment = "center";
			add((new FlxText(0,10,w,"PAUSED")).setFormat(null,16,0xffffff,"center"),true);
			add(new FlxSprite(4,36,ImgKeyP),true);
			add(new FlxText(16,36,w-16,"Pause Game"),true);
			add(new FlxSprite(4,50,ImgKey0),true);
			add(new FlxText(16,50,w-16,"Mute Sound"),true);
			add(new FlxSprite(4,64,ImgKeyMinus),true);
			add(new FlxText(16,64,w-16,"Sound Down"),true);
			add(new FlxSprite(4,78,ImgKeyPlus),true);
			add(new FlxText(16,78,w-16,"Sound Up"),true);
		}
	}
