package core.ui;

import core.define.Defines;
import core.structure.ChoiceStructure;
import flixel.addons.ui.FlxBaseMultiInput;
import flixel.addons.ui.FlxMultiKey;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUISubState;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.U;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import haxe.xml.Fast;

typedef UIUtil = flixel.addons.ui.U;

/**
 * ...
 * @author User
 */
class UIChoiceDialogSubState extends FlxUISubState
{
    private var _clickChoiceCallback:Int->Array<Dynamic>->Void;
    
    private var _buttons:Array<FlxUIButton>;
    
    private var _choiceData:ChoiceStructure;
    
    public function new(BGColor:FlxColor=0) 
    {
        super(BGColor);
    }
    
    /**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
        //A tricky way to avoid call create multiple times
        if (this._ui != null)
        {
            return;
        }
        //-------------------------------------------------------
        
        this._buttons = new Array<FlxUIButton>();
        
        this.DoXmlIdPreProcess("_ui_choice_dialog");
        
		this._makeCursor = true;
        
		super.create();
		
        //Set the Z key in keysClick.
        this.SetDefaultKeys();
        
        this._buttons.push(cast this._ui.getAsset("button_0"));
        this._buttons.push(cast this._ui.getAsset("button_1"));
        this._buttons.push(cast this._ui.getAsset("button_2"));
        this._buttons.push(cast this._ui.getAsset("button_3"));
        
        this.CleanAllElements();
	}
 
    override public function getEvent(id:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Void 
    {
        super.getEvent(id, sender, data, params);
        
        if (destroyed) 
		{ 
			return;
		}
        
		var widget:IFlxUIWidget = cast sender;
        if (widget != null && Std.is(widget, FlxUIButton))
        {
            var fuib:FlxUIButton = cast widget;
            switch (id) 
            {
                case "cursor_click", "click_button" :
                    var index:Int = -1;
                    //we've set the first param as index of button in the xml file.
                    index = (fuib.params.length > 0) ? cast(fuib.params[0], Int) : index;
                    
                    trace(id + ": " + index + " clicked");
                    
                    //also process the params might also set in the dialog xml data.
                    var params:Array<Dynamic> = UIChoiceDialogSubState.GetParams(this._choiceData.items[index]);
                    
                    trace("params: " + params);
                    
                    if (_clickChoiceCallback != null)
                    {
                        this._clickChoiceCallback(index, params);
                    }
                    
                default:
            }
        }
    }
    
    private function CleanAllElements():Void 
    {
        this.remove(cursor);
        
        for (button in this._buttons) 
        {
            this._ui.remove(button);
        }
    }
    
	@:access(Xml)
    public function ShowChoices(choiceData:ChoiceStructure, clickCallback:Int->Array<Dynamic>->Void):Void 
    {
        this._choiceData = choiceData;
        this._clickChoiceCallback = clickCallback;
        
        var title:String = UIUtil.xml_str(choiceData.rootData.x, "title");
        trace("Choice title: " + title);
        
        //Add elements
        this.CleanAllElements();
        for (i in 0 ... choiceData.items.length)
        {
            if (i >= this._buttons.length)
            {
                continue;
            }
            
            var data:Fast = choiceData.items[i];
            var button:FlxUIButton = this._buttons[i];
            
            button.label.text = UIUtil.xml_str(data.x, "text");
            
            this._ui.add(button);
        }
        
        //
        cursor.clearWidgets();
        cursor.addWidgetsFromUI(_ui);
        cursor.findVisibleLocation(0);
        this.add(cursor);
    }
    
    //{ Not very important functions
        
    private function SetDefaultKeys():Void 
    {
        //Set defualt keys
		cursor.setDefaultKeys(FlxUICursor.KEYS_ARROWS | FlxUICursor.KEYS_TAB | FlxUICursor.KEYS_WASD);
        
        //Add keys to keysClick event
        var m:FlxBaseMultiInput = new FlxMultiKey(FlxKey.Z);
		var exists:Bool = false;
		for (mk in cursor.keysClick) 
        {
			if (m.equals(mk)) 
            {
				exists = true;
				break;
			}
		}
        
		if (!exists) 
        {
			cursor.keysClick.push(m);
		}
		//
    }
    
    
    private function DoXmlIdPreProcess(xmlId:String)
    {
        this._xml_id = xmlId;

        //#if (debug && sys)
        //var directory:String = haxe.io.Path.directory(Sys.executablePath());
        //if (directory != null)
        //{
            //this._liveFilePath = directory + "/" + Defines.ASSETS_XML_PATH;
//
            //this._liveFilePath = flixel.addons.ui.U.fixSlash(_liveFilePath);
            //
            //this._xml_id = xmlId + ".xml";
        //}
        //#end
    }
    
    //Copied from FlxUI
    private static inline function GetParams(data:Fast) : Array<Dynamic>
    {
        var params:Array<Dynamic> = null;
        
        if (data.hasNode.param) 
        {
            params = new Array<Dynamic>();
            for (param in data.nodes.param) 
            {
                if (param.has.type && param.has.value)
                {
                    var type:String = param.att.type;
                    type = type.toLowerCase();
                    var valueStr:String = param.att.value;
                    var value:Dynamic = valueStr;
                    var sort:Int = flixel.addons.ui.U.xml_i(param.x, "sort",-1);
                    switch(type) {
                        case "string": value = new String(valueStr);
                        case "int": value = Std.parseInt(valueStr);
                        case "float": value = Std.parseFloat(valueStr);
                        case "color", "hex": value = flixel.addons.ui.U.parseHex(valueStr, true);
                        case "bool", "boolean": 
                            var str:String = new String(valueStr);
                            str = str.toLowerCase();
                            if (str == "true" || str == "1") 
                            {
                                value = true;
                            }
                            else
                            {
                                value = false;
                            }
                    }
                    
                    //Add sorting metadata to the array
                    params.push( { sort:sort, value:value } );
                }
            }
            
            //Sort the array
            params.sort(SortParams);
            
            //Strip out the sorting metdata
            for (i in 0...params.length) 
            {
                params[i] = params[i].value;
            }
        }
        return params;
    }
    
    private static function SortParams(a:flixel.addons.ui.FlxUI.SortValue, b:flixel.addons.ui.FlxUI.SortValue):Int
	{
		if (a.sort < b.sort) return -1;
		if (a.sort > b.sort) return 1;
		return 0;
	}
    
    //}
    
}