package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import openfl.Assets;

#if flash
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.net.FileReference;
import flash.net.FileFilter;

#elseif (cpp || neko)
import sys.io.File;

#end

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
        
        #if flash
        
            #if WIP
            var prefix:String = "../../../";
            
            var urlLoader:URLLoader = new URLLoader();
            urlLoader.addEventListener(Event.COMPLETE, this.OnScriptLoadComplete);
            urlLoader.load(new URLRequest(prefix + AssetPaths.config__hs));
            
            #else
            //Load embeded asset (flash)
            Assets.loadText(AssetPaths.config__hs, this.LoadScriptComplete);
            
            #end
            
		#elseif (cpp || neko)
        
            var prefix:String = "";
            
            #if WIP
            prefix = "../../../../";
            #end
        
            var script:String = File.getContent(prefix + AssetPaths.config__hs);
            this.LoadScriptComplete(script);
        
		#end
        
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
    
    private function LoadScriptComplete(script:String) : Void
    {
        trace("script: " + script);
        
        FlxG.log.add("assets, script: " + script);
    }
    
    #if flash
    private function OnScriptLoadComplete(e:Event):Void 
	{
        var urlLoader:URLLoader = e.target;
        urlLoader.removeEventListener(Event.COMPLETE, this.OnScriptLoadComplete);
        
        var script:String = cast(urlLoader.data, String);
        
        FlxG.log.add("loader, script: " + script);
	}
    #end
}