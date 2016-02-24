package core.util;
import flixel.FlxG;
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
    }
}