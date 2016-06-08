package core.effect;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

//This is a script base on the "BitmapDisslove.as" Lee Felarca made, here is the license they made:
/*
	BitmapDissolve.as
	Lee Felarca
	http://www.zeropointnine.com/blog
	4-7-2007
	v0.8
	
	Source code licensed under a Creative Commons Attribution 3.0 License.
	http://creativecommons.org/licenses/by/3.0/
	Some Rights Reserved.
*/


@:enum
abstract Direction(Int)
{
    var LEFT = 0;
    var DOWN = 1;
    var RIGHT = 2;
    var UP = 3;
}

@:enum
abstract Distribution(Int)
{
    var FLAT = 0;
    var CONCAVE = 1;
    //var CONVEX = 2;
}


//enum Direction
//{
    //UP;
    //RIGHT;
    //DOWN;
    //LEFT;
//}

/**
 * ...
 * @author User
 */
class FlxDissolveEffect extends FlxSprite
{
    // CONSTANTS
    //public static var DIR_LEFT:Int = 0;
    //public static var DIR_DOWN:Int = 1;
    //public static var DIR_RIGHT:Int = 2;
    //public static var DIR_UP:Int = 3;
    
    public static var DEGREE:Float = Math.PI / 180;
    
    //public static var DISTRIB_FLAT:Int = 0;
    //public static var DISTRIB_CONCAVE:Int = 1;
    //public static var DISTRIB_CONVEX:Int = 2; // (not yet implemented)
        
    // PROPERTY VARIABLES
    
    private var _numPixels:Int = 300;
    private var _duration:Int = 30;
    private var _accelRate:Float = 5;
    private var _bgColor:FlxColor = FlxColor.TRANSPARENT;
    private var _distribType:Distribution = Distribution.FLAT;
    private var _direction:Direction = Direction.LEFT;
    private var _doubleSpeed:Bool = false;

    // PRIVATE VARIABLES

    private var _srcTarget:FlxSprite;
    
    private var _bmpSource:BitmapData;
    //private var _bmpDest:BitmapData;
    
    private var _dissolovePixels:Array<Dynamic>;
    private var _xScannedTo:Array<Int>;
    
    private var _yLowerLimit:Int;
    private var _yUpperLimit:Int;
    private var _accelCounter:Float = 1;
    private var _active_pixels:Int = 1;
    private var _startedAt:Float;
    private var _frames:Int = 0;
    
    private var _update = false;
    
    private var _completeCallback:Void->Void = function ():Void {};
    
    public var DistribType(get, set):Distribution;
    private function get_DistribType():Distribution	 		            { return _distribType; }
    private function set_DistribType(i:Distribution):Distribution 	{ return _distribType = i; }

    public var DoubleSpeed(get, set):Bool;
    private function get_DoubleSpeed():Bool	 		{ return _doubleSpeed; }
    private function set_DoubleSpeed(i:Bool):Bool 	{ return _doubleSpeed = i; }
    
    public var NumPixels(get, set):Int;
    private function get_NumPixels():Int	 		{ return _numPixels; }
    private function set_NumPixels(i:Int):Int 	{ return _numPixels = i; }
    
    public var DirectionType(get, set):Direction;
    private function get_DirectionType():Direction	 		    { return _direction; }
    private function set_DirectionType(i:Direction):Direction 	{ return _direction = i; }
    
    public var Duration(get, set):Int;
    private function get_Duration():Int	 		    { return _duration; }
    private function set_Duration(i:Int):Int 	    { return _duration = i; }
    
    public function new(target:FlxSprite, ?graphic:FlxGraphicAsset) 
    {
		super();

        this._srcTarget = target;

        this._bmpSource = this._srcTarget.framePixels;
        this._xScannedTo = new Array<Int>();
        this._dissolovePixels = new Array<Dynamic>();
        
        if (graphic != null)
        {
			this.loadGraphic(graphic);
        }
        else
        {
            this.loadGraphicFromSprite(target);
        }
        
        this.x = target.x;
        this.y = target.y;
    }
    
    override public function update(elapsed:Float):Void 
    {
        super.update(elapsed);
        
        if (this._update == false)
        {
            return;
        }
        
        this._frames++;
        this._accelCounter = (this._accelCounter < this._numPixels) ?  this._accelCounter + this._accelRate : this._accelCounter;

        var length:Int = (this._accelCounter > this._numPixels) ? this._numPixels : Math.floor(this._accelCounter);
        this._active_pixels = 0;
        for (i in 0 ... length) 
        {
            if (this._dissolovePixels[i].active == true) 
            {
                this.UpdatePixel(i);
                
                this._active_pixels++;
            } 
            else 
            {
                this.FindNextPixel(i);
            }
        }
        
        if (this._active_pixels == 0 && this._accelCounter >= this._numPixels) // done
        {
            this._update = false;

            var ms:Float = Date.now().getTime() - this._startedAt;
            //var e:BitmapDissolveEvent = new BitmapDissolveEvent(BitmapDissolveEvent.DISSOLVED);
            //e.milliseconds = ms;
            //e.frames = _frames;
            //dispatchEvent(e);	
            trace("Dissolove done: " + ms);
            //Complete callback
            this._completeCallback();
        }
    
        // note, _yUpperLimit - _yLowerLimit == 1 when last _pixel is eaten
    }
    
    public function StartEffect(callback:Void->Void = null):Void
    {
        this._completeCallback = (callback == null) ? _completeCallback : callback;
        
        if (this._direction == Direction.LEFT) // DEFAULT
        {
            this._bmpSource = new BitmapData(this._srcTarget.framePixels.width, this._srcTarget.framePixels.height, true, 0);
            //this._bmpSource.copyPixels(this._srcTarget.framePixels, this._srcTarget.framePixels.rect, new Point(0, 0), null, null, true);
            this._bmpSource.draw(this._srcTarget.framePixels);
        }
        else	// rotation shenanigans 
        {	
            // [1] make copy of source bitmap
            var bmpD:BitmapData = new BitmapData(this._srcTarget.framePixels.width, this._srcTarget.framePixels.height, true, 0);
            bmpD.draw(this._srcTarget.framePixels);
            // [2] make rotation matrix
            var mRot:Matrix = new Matrix();
            mRot.rotate(DEGREE * 90 * cast(_direction, Float));
            var mTrans:Matrix = new Matrix();
            
            if (this._direction == Direction.RIGHT) // rotates bitmap 180 degrees, rotates sprite 180 degrees
            { 	
                // [3] make translation matrix, concatenate, and draw back to _sourceBitmap
                mTrans.translate(this._srcTarget.framePixels.width, this._srcTarget.framePixels.height);
                mRot.concat(mTrans);
                this._bmpSource = new BitmapData(bmpD.height, bmpD.width, true, 0);
                this._bmpSource.draw(bmpD, mRot);
                // [4] rotate movieclip 180 degrees and adjust mc position
                this.angle = 180;
                
                //this.x += this._srcTarget.framePixels.width;
                //this.y += this._srcTarget.framePixels.height;
            }
            else if (this._direction == Direction.DOWN) // direction is down (
            { 
                //same steps [3] and [4] as above, basically ...
                mTrans.translate(this._srcTarget.framePixels.height, 0);
                mRot.concat(mTrans);				
                this._bmpSource = new BitmapData(bmpD.height, bmpD.width, true, 0);
                this._bmpSource.draw(bmpD, mRot);
                
                this.angle = 270;
                //this.y += this._srcTarget.framePixels.height;
            }
            else if (this._direction == Direction.UP) // direction is up (
            { 
                //same steps [3] and [4] as above, basically ...
                mTrans.translate(0, this._srcTarget.framePixels.width);
                mRot.concat(mTrans);
                this._bmpSource = new BitmapData(bmpD.height, bmpD.width, true, 0);
                this._bmpSource.draw( bmpD, mRot);
                
                this.angle = 90;
                //this.x += this._srcTarget.framePixels.width;
            }
        }	
		
        this.framePixels = new BitmapData(_bmpSource.width, _bmpSource.height, true, 0);
        this.framePixels.draw(_bmpSource);
        
        for (i in 0 ... this._numPixels)
        {
            this._dissolovePixels[i] = {};
        }

        for (i in 0 ... this._srcTarget.framePixels.height) 
        {
            this._xScannedTo[i] = 0;
        }
        
        this._yLowerLimit = 0;
        this._yUpperLimit = this._srcTarget.framePixels.height;
        
        //addEventListener(Event.ENTER_FRAME, onEnterFrame);
        
        this._startedAt = Date.now().getTime();
        
        this._update = true;
    }
    
    public function ResumeEffect():Void 
    {
        this._update = true;
    }
    
    public function StopEffect():Void
    {
        this._update = false;
    }
    
    private function UpdatePixel(i:Int):Void
    {
        var pixel:Dynamic = this._dissolovePixels[i];
        
        this.framePixels.setPixel32(pixel.x, pixel.y, this._bmpSource.getPixel32(pixel.x, pixel.y)); 	
        // erase last position
    
        pixel.x -= pixel.velx;
        pixel.y -= pixel.vely;
        pixel.lifeleft--;
        
        if (pixel.lifeleft && pixel.x > 0) 
        {
            this.framePixels.setPixel32(pixel.x, pixel.y, pixel.color); // draw new point
        } 
        else 
        {
            pixel.active = false;
        }
    }
    
    private function FindNextPixel(i:Int):Void
    {
        // find a y value to scan thru
        
        var y0:Float;
        var y:Int;
        
        if (this._distribType == Distribution.CONCAVE) 
        {
            y0 = Math.random() * 180; // range 0 to 180
            y0 = Math.cos( y0 * DEGREE); // range 0 to 1
            //trace(y0);
            y0 *= this._srcTarget.framePixels.height; // range -height to height
            y0 /= 2; // range -halfheight to halfheight
            y0 += this._srcTarget.framePixels.height/2; // range 0 to height
        } 
        //else if (this._distribType == Distribution.CONVEX) 
        //{ 
            //y0 = Math.random() * _bitmapHeight;
        //} 
        else 
        {
            y0 = Math.random() * this._srcTarget.framePixels.height;
        }
        
        y = Math.floor(y0);
        
        var yStartedAt:Int = y;
        
        // scan upward if y is in top half
        if (y < this._srcTarget.framePixels.height/2) 
        {
            while (this._xScannedTo[y] >= this._srcTarget.framePixels.width && y >= this._yLowerLimit) 
            { 
                y--; 
            }
            
            if (this._xScannedTo[y - 1] < this._xScannedTo[y]) y = y - 1; // (helps even out 'jaggies')
            
            if (y <= this._yLowerLimit) 
            { 
                if (yStartedAt > this._yLowerLimit) 
                {
                    this._yLowerLimit = yStartedAt;
                    return;
                }  
            }	
        } 
        else 
        {
            // mirror image of above -- scan downards if y is in the bottom half
            while (this._xScannedTo[y] >= this._srcTarget.framePixels.width && y < this._yUpperLimit) 
            { 
                y++; 
            }
            
            if (this._xScannedTo[Math.round(y + 1)] < this._xScannedTo[y]) y = Math.round(y + 1); 
    
            if (y >= this._yUpperLimit) 
            { 
                if (yStartedAt < this._yUpperLimit) 
                {
                    this._yUpperLimit = yStartedAt;
                    return;
                }  
            }	
        }
        
        var findPixel = false;
        // scan across for nonblank _pixel
        var startX:Int = _xScannedTo[y];
        //for (i in x ... this._srcTarget.framePixels.width)
        for (x in startX ... this._srcTarget.framePixels.width)
        {
            if (this._bmpSource.getPixel32(x, y) != this._bgColor) 
            {
                var pixel:Dynamic = this._dissolovePixels[i];
                
                // set new point
                pixel.active = true;
                pixel.color = this._bmpSource.getPixel32(x,y);
                pixel.x = x;
                pixel.y = y;
                //pixel.wasx = -1;
                //pixel.wasy = -1;
                pixel.velx = Math.random()*1 + 1;
                pixel.vely = Math.random()*0.5 - 0.25;
                pixel.lifeleft = _duration;			
                
                this._bmpSource.setPixel32(x, y, this._bgColor); // 'erase' that point in the source
                
                if (this._doubleSpeed == true) 
                {
                    //why
                    this._bmpSource.setPixel32(x + 1, y, this._bgColor); 
                    this.framePixels.setPixel32(x + 1, y, this._bgColor);
                }
                
                this._xScannedTo[y] = x;
                
                findPixel = true;
                break;
            }
        }
    
        if (findPixel == false) this._xScannedTo[y] = this._srcTarget.framePixels.width;
    }
}