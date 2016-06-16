package core.system;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxSubState;

/**
 * Because the features of substates,
 * I'm going to use it like a "list of sub-logic", it might contain FlxUISubState or SubFlxState
 * @author User
 */
class FlxSubStateManager extends FlxObject
{
    private static var ms_Instance:FlxSubStateManager;
    
    private var _subStates:Array<FlxSubState>;
    
    private function new() 
    {
        super();
        
        this._subStates = new Array<FlxSubState>();
    }
    
    override public function destroy():Void 
    {
        super.destroy();
        
        ms_Instance = null;
        
        this._subStates.splice(0, this._subStates.length);
    }
    
    public function CloseSubState(subState:FlxSubState) : Bool
    {
        var index:Int = this._subStates.indexOf(subState);
        if (index == -1)
        {
            trace("FlxSubStateManager: can't find the substate: " + subState + " from the subState list");
            return false;
        }
        
        var parent:FlxState = FlxG.state;
        parent = (index > 0) ? this._subStates[index - 1] : parent;
        
        //remove and close
        this._subStates.remove(subState);
        
        parent.closeSubState();
        
        return true;
    }
    
    public function OpenSubState(subState:FlxSubState) : Bool 
    {
        if (this._subStates.indexOf(subState) != -1)
        {
            trace("FlxSubStateManager: there is already a substate: " + subState + " in the subState list");
            trace("FlxSubStateManager: won't do the request for now, because it's not allow to happen currently.");
            return false;
        }
        
        var parent:FlxState = FlxG.state;
        parent = (this._subStates.length > 0) ? this._subStates[this._subStates.length - 1] : parent;
        
        //add and open
        this._subStates.push(subState);
        
        parent.openSubState(subState);
        
        return true;
    }
    
    public static function Get() : FlxSubStateManager
    {
        if (ms_Instance == null)
        {
            ms_Instance = new FlxSubStateManager();
            
            FlxG.state.add(ms_Instance);
        }
        
        return ms_Instance;
    }
}