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
    public static function CommonInitial(interp:Interp) : Void
    {
        interp.variables.set("FlxG", FlxG);
        interp.variables.set("FlxTween", FlxTween);
    }
    
    public static function ExcludeExt(str:String) : String
    {
        var lastIndex:Int = str.lastIndexOf(".");
        lastIndex = (lastIndex == -1) ? str.length : lastIndex;
        
        return str.substring(0, lastIndex);
    }
}