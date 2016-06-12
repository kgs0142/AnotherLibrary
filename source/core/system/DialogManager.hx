package core.system;

import core.ui.UIDialogText;
import flash.display3D.textures.Texture;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIRegion;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.U;
import flixel.FlxG;
import flixel.FlxObject;
import haxe.xml.Fast;

@:enum
abstract MainDialogType(Int)
{
    var WO_HEAD_TITLE = 0;
    var W_HEAD = 1;
    var W_TITLE = 2;
    var W_HEAD_TITLE = 3;
}

/**
 * ...
 * @author User
 */
class DialogManager extends FlxObject
{
    //Constants
    private static inline var DT_BG_NAME:String = "dt_bg"; 
    private static inline var DT_NAME_NAME:String = "dt_name"; 
    private static inline var DT_HEAD_NAME:String = "dt_head"; 
    private static inline var DT_TITLE_NAME:String = "dt_title"; 
    private static inline var DT_TXT_W_HEAD_TITLE_NAME:String = "dt_text_w_head_title"; 
    private static inline var DT_TXT_W_HEAD_NAME:String = "dt_text_w_head"; 
    private static inline var DT_TXT_W_TITLE_NAME:String = "dt_text_w_title"; 
    private static inline var DT_TXT_WO_HEAD_TITLE_NAME:String = "dt_text_wo_head_title"; 
    private static inline var FLOAT_DT_BG_NAME:String = "float_dt_bg"; 

    //
    private var _ui:FlxUI;
    
    //Float Dialog elements
    private var _floatDt:UIDialogText;
    
    private var _floatDtBg:FlxUISprite;
    //----------------------------------------------------------------------------------
    
    //Main Dialog elements (most of them we just wnat the transform data)
    private var _mainDt:UIDialogText;
    
    private var _mainDtBg:FlxUISprite;
    private var _mainDtNameText:FlxUIText;
    private var _mainDtTitleText:FlxUIText;
    private var _mainDtHeadRegion:FlxUIRegion;
    private var _mainDtTxtWHTRegion:FlxUIRegion;
    private var _mainDtTxtWHRegion:FlxUIRegion;
    private var _mainDtTxtWTRegion:FlxUIRegion;
    private var _mainDtTxtWOHTRegion:FlxUIRegion;
    
    //TODO: Dialog Choices here
    
    //----------------------------------------------------------------------------------
    
    public function new() 
    {
        super();
    }
    
    override public function destroy():Void 
    {
        super.destroy();
        
        //this.RemoveAllElements();
        
        this.ClearAllElements();
    }
    
    public function Initial(ui:FlxUI) : Void 
    {
        this._ui = ui;
        
        //Float Dialog
        this._floatDt = new UIDialogText();
        
        //Main Dialog
        this._mainDt = new UIDialogText();
        
        this.GetInitialAssets();
        
        //remove all the elements.
        this.RemoveAllElements();
    }
    
    //{ Functions not so importants
    private function GetInitialAssets():Void 
    {
        //Float Dialog
        this._floatDtBg = cast this._ui.getAsset(FLOAT_DT_BG_NAME);
        
        //Main Dialog
        this._mainDtBg = cast this._ui.getAsset(DT_BG_NAME);
        this._mainDtNameText = cast this._ui.getAsset(DT_NAME_NAME);
        this._mainDtHeadRegion = cast this._ui.getAsset(DT_HEAD_NAME);
        this._mainDtTitleText = cast this._ui.getAsset(DT_TITLE_NAME);
        this._mainDtTxtWHTRegion = cast this._ui.getAsset(DT_TXT_W_HEAD_TITLE_NAME);
        this._mainDtTxtWHRegion = cast this._ui.getAsset(DT_TXT_W_HEAD_NAME);
        this._mainDtTxtWTRegion = cast this._ui.getAsset(DT_TXT_W_TITLE_NAME);
        this._mainDtTxtWOHTRegion = cast this._ui.getAsset(DT_TXT_WO_HEAD_TITLE_NAME);
    }
    
    private function AddUIElements(title:String, headPicAnim:String, speaker:String):Void 
    {
        this._ui.add(this._mainDtBg);
        if (title != "")
        {
            this._mainDtTitleText.text = title;
            this._ui.add(this._mainDtTitleText);
        }
        
        if (headPicAnim != "")
        {
            trace("play headAnim: " + headPicAnim);
            //this._ui.add(this._mainDtHeadRegion);
        }
        
        if (speaker != "")
        {
            this._mainDtNameText.text = speaker;
            this._ui.add(this._mainDtNameText);
        }
    }
    
    private function RemoveAllElements():Void 
    {
        if (_floatDtBg != null) this._ui.remove(_floatDtBg);
        if (_mainDtBg != null) this._ui.remove(_mainDtBg);
        if (_mainDtNameText != null) this._ui.remove(_mainDtNameText);
        if (_mainDtHeadRegion != null) this._ui.remove(_mainDtHeadRegion);
        if (_mainDtTitleText != null) this._ui.remove(_mainDtTitleText);
        if (_mainDtTxtWHTRegion != null) this._ui.remove(_mainDtTxtWHTRegion);
        if (_mainDtTxtWHRegion != null) this._ui.remove(_mainDtTxtWHRegion);
        if (_mainDtTxtWTRegion != null) this._ui.remove(_mainDtTxtWTRegion);
        if (_mainDtTxtWOHTRegion != null) this._ui.remove(_mainDtTxtWOHTRegion);
    }
    
    private function ClearAllElements():Void 
    {
        _floatDtBg = null;
        _mainDtBg = null;
        _mainDtNameText = null;
        _mainDtHeadRegion = null;
        _mainDtTitleText = null;
        _mainDtTxtWHTRegion = null;
        _mainDtTxtWHRegion = null;
        _mainDtTxtWTRegion = null;
        _mainDtTxtWOHTRegion = null;
    }
    
    //}
    
	@:access(Xml)
    public function ProcessMainDialogData(content:Fast, completeCallback:Void->Void):Void 
    {
        var name:String = U.xml_str(content.x, "name");
        var title:String = U.xml_str(content.x, "title");
        var headPicAnim:String = U.xml_str(content.x, "head");
        var speaker:String = U.xml_str(content.x, "speaker");
        
        //decide the region for DialogText.
        var region:FlxUIRegion = this._mainDtTxtWOHTRegion;
        if (title != "" && headPicAnim != "")
        {
            region = this._mainDtTxtWHTRegion;
        }
        else if (title != "")
        {
            region = this._mainDtTxtWTRegion;
        }
        else if (headPicAnim != "")
        {
            region = this._mainDtTxtWHRegion;
        }
        
        //Add UI elements
        this.AddUIElements(title, headPicAnim, speaker);
        
        //UIDialogText
        this._mainDt.SetDefaultSetting();
        this._mainDt.SetData(region, content);
        this._ui.add(_mainDt);
        
        this._mainDt.start(0.1, false, false, null, function ():Void 
        {
            this.RemoveAllElements();
            
            completeCallback();
        });
    }
    
    public function SetMainDialog(type:MainDialogType = MainDialogType.WO_HEAD_TITLE) : Void 
    {
        
    }
}