package core.util;

#if flash
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flixel.FlxG;

#elseif (cpp || neko)
import sys.io.File;

#end

/**
 * Load script files (hscript, xml...) as dynamically as possible.
 * @author User
 */
class ScriptLoader
{

    private static var ms_Instance:ScriptLoader;
    
    private var m_scriptMap:Map<String, String>;
    
    public function new() 
    {
        this.m_scriptMap = new Map<String, String>();
    }

    public function Destory():Void 
    {
        this.m_scriptMap = null;
    }
    
    public function LoadScript(pathId:String, callback:String->Void, force:Bool = false) : Void
    {
        if (force == false && this.m_scriptMap.exists(pathId))
        {
            callback(this.m_scriptMap.get(pathId));
            return;
        }
        
        this.DoLoadScript(pathId);
    }
    
    private function DoLoadScript(pathId:String):Void 
    {
        //callbacks
        var LoadScriptComplete:String->Void = function (script:String) : Void
        {
            trace("script: " + script);

            FlxG.log.add("assets, script: " + script);
        }
        
        #if flash
        
            var OnScriptLoadComplete:Event->Void = function (e:Event) : Void
            {
                var urlLoader:URLLoader = e.target;
                urlLoader.removeEventListener(Event.COMPLETE, arguments.callee);
                
                var script:String = cast(urlLoader.data, String);
                
                FlxG.log.add("loader, script: " + script);
            }
        
            #if WIP
            var prefix:String = "../../../";
            var urlLoader:URLLoader = new URLLoader();
            urlLoader.addEventListener(Event.COMPLETE, OnScriptLoadComplete);
            urlLoader.load(new URLRequest(prefix + AssetPaths.config__hs));
            
            #else
            //Load embeded asset (flash)
            Assets.loadText(AssetPaths.config__hs, LoadScriptComplete);
            
            #end
            
		#elseif (cpp || neko)
        
            var prefix:String = "";
            
            #if WIP
            prefix = "../../../../";
            #end
        
            var script:String = File.getContent(prefix + AssetPaths.config__hs);
            LoadScriptComplete(script);
        
        #else
        
            //Load embeded asset (flash)
            Assets.loadText(AssetPaths.config__hs, LoadScriptComplete);
            
		#end
    }
    
    public static function Get() : ScriptLoader
    {
        if (ms_Instance == null)
        {
            ms_Instance = new ScriptLoader();
        }
        
        return ms_Instance;
    }
}