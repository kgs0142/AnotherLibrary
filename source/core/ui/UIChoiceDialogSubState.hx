package core.ui;

import core.structure.ChoiceStructure;
import flixel.addons.ui.FlxBaseMultiInput;
import flixel.addons.ui.FlxMultiKey;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUISubState;
import flixel.addons.ui.interfaces.IFlxUIWidget;
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
    private var _clickChoiceCallback:Int->Void;
    
    private var _buttons:Array<FlxUIButton>;
    
    public function new(BGColor:FlxColor=0) 
    {
        super(BGColor);
    }
    
    /**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
        this._buttons = new Array<FlxUIButton>();
        
        this.DoXmlIdPreProcess("_ui_choice_dialog");
        
		this._makeCursor = true;
        
		super.create();
		
        //Set the Z key in keysClick.
        this.SetDefaultKeys();
        
        this._buttons.push(cast this._ui.getAsset("button_0"));
        this._buttons.push(cast this._ui.getAsset("button_1"));
        this._buttons.push(cast this._ui.getAsset("button_2"));
        
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
                    trace(id + ": " + fuib.params);
                    
                    if (_clickChoiceCallback != null)
                    {
                        this._clickChoiceCallback(cast(fuib.params, Int));
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
    public function ShowChoices(choiceData:ChoiceStructure, clickCallback:Int->Void):Void 
    {
        this._clickChoiceCallback = clickCallback;
        
        var title:String = UIUtil.xml_str(choiceData.rootData.x, "title");
        trace("Choice title: " + title);
        
        //Add elements
        this.add(cursor);
        
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

        #if (debug && sys)
        var directory:String = haxe.io.Path.directory(Sys.executablePath());
        if (directory != null)
        {
            this._liveFilePath = directory + "/" + Defines.ASSETS_XML_PATH;

            this._liveFilePath = flixel.addons.ui.U.fixSlash(_liveFilePath);
            
            this._xml_id = xmlId + ".xml";
        }
        #end
    }
    //}
    
}