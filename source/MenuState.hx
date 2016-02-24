package ;

import core.util.ScriptLoader;
import flixel.FlxG;
import flixel.FlxState;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();
        
        FlxG.debugger.visible = true;
        
        ScriptLoader.Get().LoadScript(AssetPaths.config__hs, function(script:String):Void
        {
            trace("I got the script: " + script);
            FlxG.log.add("I got the script: " + script);
        });
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(FlxG.elapsed);
	}
}