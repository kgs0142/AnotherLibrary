package core.util;


import flixel.animation.FlxAnimationController;
import flixel.FlxSprite;
import openfl.utils.Dictionary.Dictionary;


/**
 * The lasy use tool for adding animation and some simple animation event.
 * @author User
 */
class AnimationTool
{
    private static var ms_Instance:AnimationTool;

    private var _sprMap:Map<FlxSprite, CustomAnimEventRegister>;
    
    private function new() 
    {
        this._sprMap = new Map<FlxSprite, CustomAnimEventRegister>();
    }
    
    public function Destory() : Void 
    {
        this._sprMap = null;
    }
    
    //{ FlxAnimationController functions 
    public function Add(spr:FlxSprite, name:String, frames:Array<Int>, frameRate:Int = 30, looped:Bool = true, flipX:Bool = false, flipY:Bool = false) : Void
    {
        spr.animation.add(name, frames, frameRate, looped, flipX, flipY);
    }
    
    public function AddAnimEvent(spr:FlxSprite, name:String, frameNumber:Int, callback:Void->Void) : Void 
    {
        this.TryAddSpriteInMap(spr);
        this._sprMap[spr].AddAnimationEvent(name, frameNumber, callback);
    }
    
    public function RemoveAnimEvent(spr:FlxSprite, name:String, frameNumber:Int, callback:Void->Void) : Void 
    {
        this.TryAddSpriteInMap(spr);
        this._sprMap[spr].RemoveAnimationEvent(name, frameNumber, callback);
    }
    
    public function AddAnimFinishEvent(spr:FlxSprite, name:String, callback:Void->Void) : Void 
    {
        this.TryAddSpriteInMap(spr);
        this._sprMap[spr].AddFinishAnimationEvent(name, callback);
    }
    
    public function RemoveAnimFinishEvent(spr:FlxSprite, name:String, callback:Void->Void) : Void 
    {
        this.TryAddSpriteInMap(spr);
        this._sprMap[spr].RemoveFinishAnimationEvent(name, callback);
    }
    
    private function TryRemoveSpriteFromMap(spr:FlxSprite):Void 
    {
        if (this._sprMap.exists(spr) == false)
        {
            return;
        }
        
        this._sprMap[spr].Destroy();
        this._sprMap.remove(spr);
    }
    
    private function TryAddSpriteInMap(spr:FlxSprite):Void 
    {
        if (this._sprMap.exists(spr) == true)
        {
            return;
        }
        
        this._sprMap[spr] = new CustomAnimEventRegister(spr.animation);
    }
    //}
    
    public static function Get() : AnimationTool
    {
        if (ms_Instance == null)
        {
            ms_Instance = new AnimationTool();
        }
        
        return ms_Instance;
    }
}

class CustomAnimEventRegister
{
    private var _animController:FlxAnimationController;
    
    //{ Regualr animation events
    //private var _nameList:List<String>;
    //private var _frameNumberListMap:Dictionary<String, List<Int>>;
    //private var _callbackMap:Dictionary<Int, Void->Void>;
    
    // name => [frame...frame] => [callback....callback]
    private var _callbackMap:Map<String, Map<Int, Array<Void->Void>>>;
    //}
    
    //Animation finished event
    private var _finishCallbackMap:Map<String, Array<Void->Void>>;
    
    public function new(controller:FlxAnimationController) 
    {
        this._animController = controller;
        
        //this._nameList = new List<String>();
        //this._frameNumberListMap = new Dictionary<String, List<Int>>();
        this._callbackMap = new Map<String, Map<Int, Array<Void->Void>>>();
        this._finishCallbackMap = new Map<String, Array<Void->Void>>();
        
        this._animController.callback = this.AnimationCallback;
        this._animController.finishCallback = this.AnimationFinishCallback;
    }
    
    public function Destroy() : Void
    {
        this._animController = null;
        //this._frameNumberListMap = null;
        this._callbackMap = null;
        this._finishCallbackMap = null;
    }
    
    //{ Register/Unregister functions
    //public function AddAnimationEvent(name:String, frameNumber:Int, frameIndex:Int):Void 
    public function AddAnimationEvent(name:String, frameNumber:Int, callback:Void->Void):Bool 
    {
        if (this._callbackMap.exists(name) == false)
        {
            this._callbackMap[name] = new Map<Int, Array<Void->Void>>();
        }
        
        var frameNumberCallbackMap:Map<Int, Array<Void->Void>> = this._callbackMap.get(name);
        if (frameNumberCallbackMap.exists(frameNumber) == false)
        {
            frameNumberCallbackMap[frameNumber] = new Array<Void->Void>();
        }
        
        var callbacks:Array<Void->Void> = frameNumberCallbackMap.get(frameNumber);
        if (Lambda.has(callbacks, callback) == true)
        {
            return false;
        }
        
        callbacks.push(callback);
        
        return true;
    }
    
    public function RemoveAnimationEvent(name:String, frameNumber:Int, callback:Void -> Void):Bool
    {
        if (this._callbackMap.exists(name) == false)
        {
            return false;
        }
        
        var frameNumberCallbackMap:Map<Int, Array<Void->Void>> = this._callbackMap.get(name);
        if (frameNumberCallbackMap.exists(frameNumber) == false)
        {
            return false;
        }
        
        var callbacks:Array<Void->Void> = frameNumberCallbackMap.get(frameNumber);
        if (Lambda.has(callbacks, callback) == false)
        {
            return false;
        }
        
        callbacks.remove(callback);
        
        return true;
    }
    
    public function AddFinishAnimationEvent(name:String, callback:Void->Void):Bool 
    {
        if (this._finishCallbackMap.exists(name) == false)
        {
            this._finishCallbackMap[name] = new Array<Void->Void>();
        }
        
        var finishCallbacks:Array<Void->Void> = this._finishCallbackMap.get(name);
        if (Lambda.has(finishCallbacks, callback) == true)
        {
            return false;
        }
        
        finishCallbacks.push(callback);
        
        return true;
    }
    
    public function RemoveFinishAnimationEvent(name:String, callback:Void->Void):Bool 
    {
        if (this._finishCallbackMap.exists(name) == false)
        {
            return false;
        }
        
        var finishCallbacks:Array<Void->Void> = this._finishCallbackMap.get(name);
        if (Lambda.has(finishCallbacks, callback) == false)
        {
            return false;
        }
        
        finishCallbacks.remove(callback);
        
        return true;
    }
    
    //}
    
    public function AnimationCallback(name:String, frameNumber:Int, frameIndex:Int):Void 
    {
        if (this._callbackMap.exists(name) == false)
        {
            return;
        }
        
        var frameNumberCallbackMap:Map<Int, Array<Void->Void>> = this._callbackMap.get(name);
        if (frameNumberCallbackMap.exists(frameNumber) == false)
        {
            return;
        }
     
        var callbacks:Array<Void->Void> = frameNumberCallbackMap.get(frameNumber);
        var length:Int = callbacks.length;
        for (i in 0 ... length) 
        {
            callbacks[i]();
        }
    }
    
    public function AnimationFinishCallback(name:String):Void 
    {
        if (this._finishCallbackMap.exists(name) == false)
        {
            return;
        }
        
        var finishCallbacks:Array<Void->Void> = this._finishCallbackMap.get(name);
        var length:Int = finishCallbacks.length;
        for (i in 0 ... length) 
        {
            finishCallbacks[i]();
        }
    }
}
