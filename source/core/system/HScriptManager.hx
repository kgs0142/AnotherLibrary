package core.system;

import flixel.FlxG;
import hscript.Parser;
import core.util.ScriptLoader;
import openfl.errors.Error;
import openfl.events.IEventDispatcher;

/**
 * ...
 * @author User
 */
class HScriptManager
{
    private static var ms_Instance:HScriptManager;

    private var m_Cache:Map<String, Dynamic>;
    
    private var m_Parser:Parser;
    
    private var m_LoadQueue:List<LoadUnit>;
    private var m_uiTotalCount:UInt;
    private var m_uiAccuCount:UInt;
    private var m_funcLoadComplete:Void->Void;
    
    public function new() 
    {
        this.m_uiAccuCount = 0;
        this.m_uiTotalCount = 0;
        this.m_Parser = new Parser();
        this.m_LoadQueue = new List<LoadUnit>();
        this.m_Cache = new Map<String, Dynamic>();
    }
    
    public function Initial(callback:Void->Void) : Void 
    {
        this.m_funcLoadComplete = callback;
        
        this.m_uiTotalCount = 0;
        this.m_LoadQueue.clear();
        
        //this.ReloadAllHScript();
    }
    
    public function Destory() : Void 
    {
    }
    
    public function ReloadAllHScript() : Void
    {
        this.m_uiAccuCount = 0;
        this.m_uiTotalCount = this.m_LoadQueue.length;
        //this.m_LoadQueue.clear();
        
        this.StartLoad();
    }
    
    public function AddLoadQueue(pathId:String, force:Bool):Void 
    {
        this.m_uiTotalCount++;
        
        this.m_LoadQueue.add(new LoadUnit(pathId, force));
    }
    
    public function GetParsedScript(pathId:String) : Dynamic
    {
        return this.m_Cache.get(pathId);
    }
    
    private function StartLoad():Void 
    {
        var singleLoadComplete:Void->Void = function ():Void 
        {
            this.m_uiAccuCount++;

            if (this.m_uiAccuCount == this.m_uiTotalCount)
            {
                trace("Load complete: " + this.m_uiAccuCount + "/" + this.m_uiTotalCount);
                
                if (this.m_funcLoadComplete != null)
                {
                    this.m_funcLoadComplete();
                }
            }
        }
        
        for (unit in this.m_LoadQueue) 
        {
            this.LoadHScript(unit.PathId, unit.Force, singleLoadComplete);
        }
    }
    
    public function LoadHScript(pathId:String, force:Bool, singleLoadComplete:Void->Void = null):Void 
    {
        var callback:String->Void = function (script:String):Void 
        {
            //trace("Single load complete:" + pathId);

            //Parsing string script.
            try 
            {
                this.m_Cache.set(pathId, this.m_Parser.parseString(script));
            }
            catch (err:Error)
            {
                FlxG.log.add(err.name + ": " + err.message);
            }
            
            if (singleLoadComplete != null)
            {
                singleLoadComplete();
            }
        }
        
        //trace("Start load:" + pathId);
        ScriptLoader.Get().LoadScript(pathId, callback, force);
    }
    
    public static function Get() : HScriptManager
    {
        if (ms_Instance == null)
        {
            ms_Instance = new HScriptManager();
        }
        
        return ms_Instance;
    }
}

class LoadUnit
{
    public var PathId:String;
	public var Force:Bool;
    
    public function new(pathId:String, force:Bool) 
    {
        this.PathId = pathId;
        this.Force = force;
    }
}