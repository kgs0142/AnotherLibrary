package core.effect;

import core.effect.LightSource.Light;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxSpriteUtil;
import openfl.display.BlendMode;


/**
 * Some implements of light source base on zerolib made by 01010111 - https://github.com/01010111/zerolib
 * Overall, the light is made from blend mode: Multiply and Screen
 * @author TajamSoft
 * @author 01010111
 * @author User
 */
class LightSource extends FlxSprite
{
    private var _darknessColor:Int = 0x00000000;
    private var _lights = new FlxTypedGroup<Light>();
    
    public function new(darknessColor:Int = 0xd0000010) 
	{
		super();
		
		this.makeGraphic(FlxG.width, FlxG.height, darknessColor);
        
		this.scrollFactor.set(0, 0);
		this.blend = BlendMode.MULTIPLY;
		this._darknessColor = darknessColor;
		
		this._lights = new FlxTypedGroup<Light>();
	}
    
	public function AddToState():Void
	{
		FlxG.state.add(this);
		FlxG.state.add(this._lights);
	}
    
    override public function update(elapsed:Float):Void 
	{
        super.update(elapsed);

		FlxSpriteUtil.fill(this, _darknessColor);
		
		for (light in this._lights)
		{
			light.alpha = 1;
			this.stamp(light, Std.int(light.x), Std.int(light.y));
			light.alpha = 0;
		}
	}
    
    //{ CustomLight
	public function AddCustomLightTarget(target:FlxObject, SimpleGraphic:FlxGraphicAsset, Width:Int, Height:Int, Frames:Array<Int>, FrameRate:Int):Void
    {
        var customLight:CustomLight = new CustomLight(SimpleGraphic, Width, Height, Frames, FrameRate);
        customLight.SetFollowTarget(target);
		this._lights.add(customLight);
    }
    //}
    
    //{ SpotLights
    
	public function AddSpotLightTarget(target:FlxObject, lightSize:Int):Void
	{
        var spotLight:SpotLight = new SpotLight(lightSize);
        spotLight.SetFollowTarget(target);
		this._lights.add(spotLight);
	}
	
	public function AddSpotLightTargets(targets:FlxTypedGroup<FlxObject>, lightSize:Int):Void
	{
		for (target in targets)
		{
			this.AddSpotLightTarget(target, lightSize);
		}
	}
    //}
    
}

class Light extends FlxSprite
{
    private var _target:FlxObject;

	public function new (?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset):Void
    {
        super(X, Y, SimpleGraphic);
    }
    
    public function SetFollowTarget(target:FlxObject):Void 
    {
        _target = target;
        var sf = _target.exists ? 1 : 0;
		this.scale.set(sf, sf);
    }
}

class CustomLight extends Light 
{
	public function new (SimpleGraphic:FlxGraphicAsset, Width:Int, Height:Int, Frames:Array<Int>, FrameRate:Int):Void
    {
        super();
        
        this.loadGraphic(SimpleGraphic, true, Width, Height);
        this.animation.add("default", Frames, FrameRate);
        this.animation.play("default");
        
		this.blend = BlendMode.SCREEN;
    }
    
    override public function update(elapsed:Float):Void 
	{
        if (_target != null)
        {
            var pos = FlxPoint.get((this._target.getScreenPosition().x + this._target.width * 0.5) - this.width * 0.5, 
                                   (this._target.getScreenPosition().y + this._target.height * 0.5) - this.height * 0.5);
            
            if (this.getMidpoint().distanceTo(this._target.getMidpoint()) > 32)
            {
                this.setPosition(pos.x, pos.y);
            }
            else
            {
                x += (pos.x - x) * 0.5;
                y += (pos.y - y) * 0.5;
            }
            
            var s = _target.exists ? 1 : 0;
            scale.x += (s - scale.x) * 0.05;
            scale.y += (s - scale.y) * 0.05;
		}
        
		super.update(elapsed);
	}
}

class SpotLight extends Light 
{
	public function new (lightSize:Int):Void
	{
        super();

		this.makeGraphic(lightSize, lightSize, 0x00ffffff);
		FlxSpriteUtil.drawCircle(this);
        
		this.blend = BlendMode.SCREEN;
	}
	
	override public function update(elapsed:Float):Void 
	{
        if (_target != null)
        {
            var pos = FlxPoint.get((this._target.getScreenPosition().x + this._target.width * 0.5) - this.width * 0.5, 
                                   (this._target.getScreenPosition().y + this._target.height * 0.5) - this.height * 0.5);
            
            if (this.getMidpoint().distanceTo(this._target.getMidpoint()) > 32)
            {
                this.setPosition(pos.x, pos.y);
            }
            else
            {
                x += (pos.x - x) * 0.5;
                y += (pos.y - y) * 0.5;
            }
            
            var s = _target.exists ? 1 : 0;
            scale.x += (s - scale.x) * 0.05;
            scale.y += (s - scale.y) * 0.05;
		}
        
		super.update(elapsed);
	}
}