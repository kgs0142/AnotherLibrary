package core.util;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import hscript.Interp;

/**
 * ...
 * @author User
 */
class CustomExtension
{
    public static function CommonInitial(interp:Interp) 
    {
        interp.variables.set("FlxG", FlxG);
        interp.variables.set("FlxTween", FlxTween);
    }
}