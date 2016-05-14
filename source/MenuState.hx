package ;

import core.misc.CustomInterp;
import core.system.HScriptManager;
import core.ui.UIDialogText;
import core.util.ScriptLoader;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import flixel.tweens.FlxTween;

using core.util.CustomExtension;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
    private var player:Player;
    private var interp:CustomInterp;
    
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();
        
        player = new Player();
        this.add(player);
        
        //testing some debug feature
        //FlxG.debugger.visible = true;
        
        FlxG.debugger.addTrackerProfile(new TrackerProfile(Player, ["isReadyToJump", "_shootCounter", "_jumpPower"], [FlxBasic]));
        //FlxG.debugger.addTrackerProfile(new TrackerProfile(Player, ["isReadyToJump", "_shootCounter", "_jumpPower"], [FlxSprite]));
        
        FlxG.debugger.track(player);
        
        FlxG.bitmapLog.add(player.pixels);
        FlxG.console.registerObject("player", player);
        FlxG.console.registerFunction("testPrintSomething", function ():Void 
        {
            FlxG.log.add("just test print something.");
        });
        //-------------------------------------------------------------------------------------
        
        //Dialog box, with delay char and custom code (dialog audio)
        var dialog:UIDialogText = new UIDialogText(10, 10, 150, 
        "Muhahahah, yahahaha, wahahaha, ::sound:assets/sounds/dialog/hello:hello.", 8);
        this.add(dialog);
        dialog.start(0.1);
        //-------------------------------------------------------------------------------------
        
        //HScriptManager AddQueue, ReloadAllHScript
        interp = new CustomInterp();
        interp.CommonInitial();
        interp.variables.set("player", player);
        interp.variables.set("testCreateFunction", function () : Void {});
        interp.variables.set("testUpdateFunction", function () : Void {});
        
        #if WIP
        var force:Bool = true;
        #else
        var force:Bool = false;
        #end
        
        HScriptManager.Get().Initial(function ():Void 
        {
            trace("HScriptManager.Get().Initial Complete");
            
            var GetParsedScript:String->Dynamic = HScriptManager.Get().GetParsedScript;
            
            interp.execute(GetParsedScript(AssetPaths.config__hs));
            
            interp.variables.get("testCreateFunction")();
        });
        
        //Queue
        HScriptManager.Get().AddLoadQueue(AssetPaths.config__hs, force);
        
        HScriptManager.Get().ReloadAllHScript();
        //--------------------------------------------------------------------------------------
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
		super.update(elapsed);
        
        interp.variables.get("testUpdateFunction")(elapsed);
	}
}

class Player extends FlxSprite
{
    private  var isReadyToJump:Bool;
    private  var _shootCounter:Float;
    private  var _jumpPower:Float;
}