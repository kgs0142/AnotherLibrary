package core.structure;

import haxe.xml.Fast;

/**
 * ...
 * @author User
 */
class ChoiceStructure 
{
    public var rootData:Fast;
    public var items:Array<Fast>;
    
    public function new()
    {
        items = new Array<Fast>();
    }
}