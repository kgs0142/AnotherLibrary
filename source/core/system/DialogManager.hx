package core.system;

import core.define.Defines;
import core.misc.CustomInterp;
import core.structure.ChoiceStructure;
import core.structure.DialogNodeStructure;
import core.ui.UIChoiceDialogSubState;
import core.ui.UIDialogText;
import flash.display3D.textures.Texture;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIRegion;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.U;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import haxe.xml.Fast;

using core.util.CustomExtension;

@:enum
abstract MainDialogType(Int)
{
    var WO_HEAD_TITLE = 0;
    var W_HEAD = 1;
    var W_TITLE = 2;
    var W_HEAD_TITLE = 3;
}

@:enum
abstract DialogContentType(Int)
{
    var REGULAR_DIALOG = 0;
    var DRAMA = 1;
    var CHOICE = 2;
    var GOTO = 3;
    var LEAVE = 4;
    var SCRIPT = 5;
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

    private static var ms_Instance:DialogManager;
    
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
    
    //{ Lots of default setting, WIP
    private var _mainDtNameTextColor:FlxColor;
    //}
    
    //TODO: Dialog Choices here
    
    //----------------------------------------------------------------------------------
    
    //Drama
    private var _interpDrama:CustomInterp;
        
    //Script
    private var _interpScript:CustomInterp;

    
    //Datas
    private var _dialogList:List<DialogNodeStructure>;
    private var _defaultDialogNode:DialogNodeStructure;
    private var _choiceDatas:Array<ChoiceStructure>;
    private var _dialogNodeDatas:Array<DialogNodeStructure>;
    //----------------------------------------------------------------------------------
    
    
    private function new() 
    {
        super();
                
        this._choiceDatas = new Array<ChoiceStructure>();
        this._dialogNodeDatas  = new Array<DialogNodeStructure>();
    }
    
    override public function destroy():Void 
    {
        super.destroy();
        
        //this.RemoveAllElements();
        
        this.ClearAllElements();
        
        ms_Instance = null;
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
        
        //Drama initial
        this._interpDrama = new CustomInterp();
        this._interpDrama.CommonInitial();
        this._interpDrama.variables.set("this", this);
        
        //Script Initial
        this._interpScript = new CustomInterp();
        this._interpScript.CommonInitial();
        this._interpScript.variables.set("this", this);
        
        var GetParsedScript:String->Dynamic = HScriptManager.Get().GetParsedScript;
        this._interpScript.execute(GetParsedScript(AssetPaths.dialogManager__hs));
    }
    
    //The first and main logic to push this system forward.
    public function DoNextDialogProcess() : Void 
    {
        var node:DialogNodeStructure = this._dialogList.last();
        
        if (node == null)
        {
            trace("I supposeed this should not be happening, but it's the end");
            
            this.RemoveAllElements();
            
            //Call dialog thread complete callback.
            
            return;
        }
        
        if (node.ReachTheEnd() == true)
        {
            trace(node.Name + " already reach the end of dialog script");
            
            this._dialogList.remove(node);
            
            this.DoNextDialogProcess();
            
            return;
        }
        
        var content:Fast = node.GetCurrentContent();
        node.CurrentIndex++;

        //start running
        this.ProcessContentDialogData(content);
    }
    
    @:access(Xml)
    private function ProcessContentDialogData(content:Fast):Void 
    {
        //make sure what the functions this content want to do first, there are priority.
        var contentType:DialogContentType = DialogContentType.REGULAR_DIALOG;
        contentType = content.has.leave ? DialogContentType.LEAVE : contentType;
        contentType = content.has.script ? DialogContentType.SCRIPT : contentType;
        contentType = content.has.drama ? DialogContentType.DRAMA : contentType;
        contentType = content.has.choice ? DialogContentType.CHOICE : contentType;
        contentType = content.has.goto ? DialogContentType.GOTO : contentType;
        
        //then decide what to do.
        switch (contentType) 
        {
            case DialogContentType.DRAMA:
                this.DoDramaProcess(content);
                return;
            
            case DialogContentType.GOTO:
                this.DoGotoProcess(content);
                return;
                
            case DialogContentType.CHOICE:
                this.DoChoiceProcess(content);
                return;
                
            case DialogContentType.SCRIPT:
                this.DoScriptProcess(content);
                return;
                
            case DialogContentType.LEAVE:
                //Do nothing, break this dialog from the current node.
                return;
                
            default:
        }
        //-------------------------------------------------
        
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
        else if (headPicAnim != "")
        {
            region = this._mainDtTxtWHRegion;
        }
        else if (title != "" || speaker != "")
        {
            region = this._mainDtTxtWTRegion;
        }
        
        //Add UI elements
        this.AddUIElements(title, headPicAnim, speaker);
        this.SetDefaultSetting();
        this.SetUIDescription(content);
        
        //UIDialogText
        this._mainDt.SetDefaultSetting();
        this._mainDt.SetData(region, content);
        this._ui.add(_mainDt);
        
        this._mainDt.start(null, false, false, null, function ():Void 
        {
            this.RemoveAllElements();
            
            this.DoNextDialogProcess();
            //completeCallback();
        });
    }
    
    //public function SetMainDialog(type:MainDialogType = MainDialogType.WO_HEAD_TITLE) : Void 
    //{
        //
    //}
    
    //{ Set some UI description
    private function SetUIDescription(content:Fast):Void 
    {
        var speakerColor:String = flixel.addons.ui.U.xml_str(content.x, "speaker_color");
        if (speakerColor != "")
        {
            this._mainDtNameText.color = FlxColor.fromString(speakerColor);
        }
    }
    
    private function SetDefaultSetting():Void 
    {
        this._mainDtNameText.color = this._mainDtNameTextColor;
    }
    //}
    
    //{ Choice functions
    private function DoChoiceProcess(content:Fast) : Void 
    {
        var choiceName:String = U.xml_str(content.x, "choice");
        
        var choiceData:ChoiceStructure = this.GetChoiceData(choiceName);
        
        if (choiceData == null)
        {
            trace("choiceData is null.");
            
            this.DoNextDialogProcess();
            
            return;
        }
        
        var uiChoiceSubState:UIChoiceDialogSubState = new UIChoiceDialogSubState();
        uiChoiceSubState.create();
        
        var result:Bool = FlxSubStateManager.Get().OpenSubState(uiChoiceSubState);
        if (result == false)
        {
            trace("OpenSubState failed.");
            uiChoiceSubState.destroy();
            uiChoiceSubState = null;
            
            this.DoNextDialogProcess();
            
            return;
        }
        
        var clickCallback:Int->Array<Dynamic>->Void = function (index:Int, params:Array<Dynamic>) : Void 
        {
            trace("ClickChoiceHandler: " + index + ", " + params);
            
            FlxSubStateManager.Get().CloseSubState(uiChoiceSubState);
            
            //let try some simple way first, shall we?
            var itemData:Fast = choiceData.items[index];
            
            this.DoGotoProcess(itemData);
        };
        
        uiChoiceSubState.ShowChoices(choiceData, clickCallback);
    }
    
    //}
    
    //{ Goto functions
    private function DoGotoProcess(content:Fast) : Void 
    {
        var nodeName:String = U.xml_str(content.x, "goto");
        
        for (data in this._dialogNodeDatas)
        {
            if (data.Name == nodeName)
            {
                trace("Found node: " + nodeName);
                
                this._dialogList.add(data.Clone());
                
                this.DoNextDialogProcess();
                
                return;
            }
        }
        
        trace("Cannot fund the node: " + nodeName);
    }
    //}
    
    //{ Script functions
    private function DoScriptProcess(content:Fast) : Void 
    {
        var funcName:String = U.xml_str(content.x, "script");
        this._interpScript.variables.get(funcName)();
        
        this.DoNextDialogProcess();
    }
    
    public function SetScriptVariable(name:String, variable:Dynamic):Void 
    {
        this._interpScript.variables.set(name, variable);
    }
    
    //}
    
    //{ Drama functions
    private function DoDramaProcess(content:Fast) : Void 
    {
        var scriptName:String = U.xml_str(content.x, "drama");
        var pathId:String = Defines.ASSETS_DRAMA_DIALOG_PATH + scriptName;
        
        #if WIP
        var force:Bool = true;
        #else
        var force:Bool = false;
        #end
        
        var callback:Void->Void = function ():Void 
        {
            var GetParsedScript:String->Dynamic = HScriptManager.Get().GetParsedScript;
            
            _interpDrama.execute(GetParsedScript(pathId));
            
            _interpDrama.variables.get("PlayDrama")();
            
            //once the drama is complete, it will call the DoDialogProcess from the hscript.
        }
        
        //Load
        HScriptManager.Get().LoadHScript(pathId, force, callback);
    }
    
    //}
    
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
        
        //Set initial settings
        this._mainDtNameTextColor = this._mainDtNameText.color;
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
        if (_mainDt != null) this._ui.remove(_mainDt);
        
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
        _mainDt = null;
        
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
    
    private function GetChoiceData(choiceName:String) : ChoiceStructure 
    {
        for (data in this._choiceDatas)
        {
            if (data.name == choiceName)
            {
                return data;
            }
        }
        
        return null;
    }
    
    public static function Get() : DialogManager
    {
        if (ms_Instance == null)
        {
            ms_Instance = new DialogManager();
            
            FlxG.state.add(ms_Instance);
        }
        
        return ms_Instance;
    }
    
    //}
        
    //{ Not very important functions
    public function LoadDialogProcess(xmlName:String) : Void 
    {
        var fast:haxe.xml.Fast;
        
        #if (debug && sys)
        var exePath:String = Sys.executablePath();
        var directory:String = haxe.io.Path.directory(exePath);
        
        //THIS IS TRICKY, but this do save some troubles for me...
        //I swaer to god I will fix this once I have the better way to get folder path of "project/assets"
        #if WIP
        var postfix = "/../../../../";
        directory = directory + postfix;
        #end
        
        //var directory:String = haxe.io.Path.directory(Sys.executablePath());
        var path:String = directory + "/" + Defines.ASSETS_DIALOG_PATH;
        path = flixel.addons.ui.U.fixSlash(path);
    
        fast = U.readFast(U.fixSlash(path + xmlName + ".xml"));

		#else
        fast = flixel.addons.ui.U.xml(xmlName, "xml", true, Defines.ASSETS_DIALOG_PATH);
		#end
        
        //Dialog nodes
        this._dialogList = new List<DialogNodeStructure>();
        this._defaultDialogNode = new DialogNodeStructure();
        this._dialogList.add(_defaultDialogNode);
        
        //Load xml file
        this.LoadDialogXml(fast, xmlName, _defaultDialogNode);
    }
    
    @:access(Xml)
    private function LoadDialogXml(data:Fast, xmlName:String, dialogNode:DialogNodeStructure) : Void
    {
        //set name, this is *IMPORTANT*
        dialogNode.Name = U.xml_name(data.x);
        
        //First, doing the inject processing
        if (data.hasNode.inject)
        {
            while(data.hasNode.inject == true)
            {
                var inj_data = data.node.inject;
                var inj_name:String = U.xml_name(inj_data.x);
                
                var payload:Xml;
                
                var directory:String = Defines.ASSETS_INJECT_DIALOG_PATH + xmlName + "/";
                #if (debug && sys && WIP)
                var exePath:String = Sys.executablePath();
                directory = haxe.io.Path.directory(exePath);
                directory = directory + "/../../../../";
                directory = directory + Defines.ASSETS_INJECT_DIALOG_PATH + xmlName + "/";
                var fast:haxe.xml.Fast = U.readFast(U.fixSlash(directory + inj_name + ".xml"));
                payload = fast.x;
                #else
                payload = U.xml(inj_name, "xml", false, directory);
                #end
                
                //var payload:Xml = U.xml(inj_name, "xml", false, directory);
                if (payload != null)
                {
                    var parent = inj_data.x.parent;
                    var i:Int = 0;
                    for (child in parent.children)
                    {
                        if (child == inj_data.x)
                        {
                            break;
                        }
                        i++;
                    }
                    
                    if (parent.removeChild(inj_data.x))
                    {
                        var j:Int = 0;
                        for (e in payload.elements())
                        {
                            parent.insertChild(e, i + j);
                            j++;
                        }
                    }
                }
            }
        }
        
        //process "content"
        if (data.hasNode.content)
        {
            for (content in data.nodes.content)
            {
                dialogNode.ContentList.push(content);
                //contentList.push(content);
            }
        }
        
        //process "choice"
        if (data.hasNode.choice)
        {
            for (choiceData in data.nodes.choice)
            {
                var choice:ChoiceStructure = new ChoiceStructure();
                //choiceList.push(choice);
                choice.rootData = choiceData;
                choice.name = U.xml_name(choiceData.x);
                if (choiceData.hasNode.item)
                {
                    for (item in choiceData.nodes.item)
                    {
                        choice.items.push(item);
                    }
                }
                
                this._choiceDatas.push(choice);
            }
        }
        
        //process "data", working like a node, leaf in a tree, but not exactly
        if (data.hasNode.data)
        {
            for (blockData in data.nodes.data)
            {
                var node:DialogNodeStructure = new DialogNodeStructure();
                _dialogNodeDatas.push(node);
                
                //recursion
                this.LoadDialogXml(blockData, xmlName, node);
            }
        }
    }
    
    //}
    
}