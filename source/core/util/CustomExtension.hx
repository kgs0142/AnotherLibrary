package core.util;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.addons.effects.chainable.FlxRainbowEffect;
import flixel.addons.effects.chainable.FlxShakeEffect;
import flixel.addons.effects.chainable.FlxTrailEffect;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUISubState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import hscript.Interp;

/**
 * ...
 * @author User
 */
class CustomExtension
{
    public static function CommonInitial(interp:Interp) : Void
    {
        interp.variables.set("FlxG", FlxG);
        interp.variables.set("FlxTween", FlxTween);
        interp.variables.set("FlxSprite", FlxSprite);
        interp.variables.set("AssetPaths", AssetPaths);
        
        //{ FlxEffectSprite
        interp.variables.set("FlxEffectSprite", FlxEffectSprite);
        interp.variables.set("FlxRainbowEffect", FlxRainbowEffect);
        interp.variables.set("FlxOutlineEffect", FlxOutlineEffect);
        interp.variables.set("FlxWaveEffect", FlxWaveEffect);
        interp.variables.set("FlxGlitchEffect", FlxGlitchEffect);
        interp.variables.set("FlxTrailEffect", FlxTrailEffect);
        interp.variables.set("FlxShakeEffect", FlxShakeEffect);
        //}
        
    }
    
    public static function ExcludeExt(str:String) : String
    {
        var lastIndex:Int = str.lastIndexOf(".");
        lastIndex = (lastIndex == -1) ? str.length : lastIndex;
        
        return str.substring(0, lastIndex);
    }
}