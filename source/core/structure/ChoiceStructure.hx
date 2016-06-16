package core.structure;

import haxe.xml.Fast;

/**
 * ...
 * @author User
 */
class ChoiceStructure 
{
    public var name:String;
    public var rootData:Fast;
    public var items:Array<Fast>;
    
    public function new()
    {
        name = "";
        items = new Array<Fast>();
    }
}