package core.structure;

import haxe.xml.Fast;

/**
 * ...
 * @author User
 */
class DialogNodeStructure
{
    private var _name:String = "";
    private var _currentIndex:Int = 0;
    private var _contentList:Array<Fast>;
    private var _choiceList:Array<ChoiceStructure>;

    public var Name(get, set):String;
    private function get_Name():String	 		            { return _name; }
    private function set_Name(i:String):String	 		    { return _name = i; }
        
    public var CurrentIndex(get, set):Int;  
    private function get_CurrentIndex():Int	 		        { return _currentIndex; }
    private function set_CurrentIndex(i:Int):Int 	        { return _currentIndex = i; }
    
    public var ContentList(get, null):Array<Fast>;
    private function get_ContentList():Array<Fast>          { return _contentList; }
    private function set_ContentList(i:Array<Fast>):Array<Fast> 	    { return _contentList = i; }
    
    public var ChoiceList(get, null):Array<ChoiceStructure>;
    private function get_ChoiceList():Array<ChoiceStructure> { return _choiceList; }
    private function set_ChoiceList(i:Array<ChoiceStructure>):Array<ChoiceStructure> 	    { return _choiceList = i; }
    
    public function new() 
    {
        this._currentIndex = 0;
        this._contentList = new Array<Fast>();
        this._choiceList = new Array<ChoiceStructure>();
    }
    
    public function GetCurrentContent() : Fast
    {
        if (this.ReachTheEnd() == true)
        {
            return null;
        }
        
        return this._contentList[this._currentIndex];
    }
    
    public function ReachTheEnd() : Bool
    {
        return (this._currentIndex >= this._contentList.length);
    }
    
    public function Clone():DialogNodeStructure 
    {
        var node:DialogNodeStructure = new DialogNodeStructure();
        node.Name = this.Name;
        node.ContentList = this._contentList.copy();
        node.ChoiceList = this._choiceList.copy();
        
        return node;
    }
}