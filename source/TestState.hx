package ;

import core.define.Defines;
import core.structure.ChoiceStructure;
import core.structure.DialogNodeStructure;
import core.system.DialogManager;
import core.ui.UIChoiceDialogSubState;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.U;
import haxe.xml.Fast;

/**
 * ...
 * @author User
 */
class TestState extends FlxUIState
{
    private var _dialogManager:DialogManager;
    
    public function new() 
    {
        super();
    }
    
    override public function create() 
	{
        this.DoXmlIdPreProcess("_ui_prefs");
        //this.DoXmlIdPreProcess(AssetPaths.test_dialog__xml);
        
		super.create();
        
        trace(this._ui);
        
        this._dialogManager = new DialogManager();
        this._dialogManager.Initial(this._ui);
        this.add(this._dialogManager);
        
        //some test--------------------------------------------------------------------------
        //var dt:UIDialogText = new UIDialogText(0, 50, 200, "TestTestTestTest,TestTestTestTest");
        //
        //var theFont:String = flixel.addons.ui.U.font("prstartk");
		//#if (flash || !openfl_legacy)
			//theFont = flixel.addons.ui.FontFixer.fix(theFont);
		//#end
        //dt.setFormat(theFont, 8);
        //dt.start(0.1);
        //this.add(dt);
        
        //FlxG.debugger.track(this._ui.members);
        
        //test choice dialog--------------------------------------------------------------------------
        //this.persistentUpdate = true;
        //this.openSubState(new UIChoiceDialogSubState());
        //return;
        
        //load dialog xml files for testing-------------------------------------
        this._dialogManager.LoadDialogProcess("testChat");
        
        this._dialogManager.DoDialogProcess();
	}
    
    private function DoXmlIdPreProcess(xmlId:String)
    {
        this._xml_id = xmlId;

        #if (debug && sys)
        var directory:String = haxe.io.Path.directory(Sys.executablePath());
        //directory = StringTools.replace(directory, "\\", "/");
        
        if (directory != null)
        {
            this._liveFilePath = directory + "/" + Defines.ASSETS_XML_PATH;

            this._liveFilePath = flixel.addons.ui.U.fixSlash(_liveFilePath);
            
            this._xml_id = xmlId + ".xml";
            
            //var fast:haxe.xml.Fast = flixel.addons.ui.U.readFast(_liveFilePath + xmlId);
            //trace(fast);
            
            //var xml:Xml = flixel.addons.ui.U.readXml(_liveFilePath + this._xml_id);
            //trace(xml);
            
            //fast = new haxe.xml.Fast(xml);
            //trace(fast);
            //FlxG.log.add(_liveFilePath);
        }

        //#else
        //
            //this._xml_id = xmlId;
        #end
    }
    
}
