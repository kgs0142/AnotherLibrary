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
        var dialogId:String = "testChat";
        var fast:haxe.xml.Fast;
        
        #if (debug && sys)
        var directory:String = haxe.io.Path.directory(Sys.executablePath());
        var path:String = directory + "/" + Defines.ASSETS_DIALOG_PATH;
        path = flixel.addons.ui.U.fixSlash(path);
    
        fast = U.readFast(U.fixSlash(path + dialogId + ".xml"));

		#else
        fast = flixel.addons.ui.U.xml(dialogId, "xml", true, Defines.ASSETS_DIALOG_PATH);
        
		#end
        
        this.dialogList = new List<DialogNodeStructure>();
        this.defaultDialogNode = new DialogNodeStructure();
        this.dialogList.add(defaultDialogNode);
        
        this.TestLoadDialogXml(fast, "firstStage", defaultDialogNode);
        
        this.DoDialogProcess();
	}
    
    private function DoDialogProcess():Void 
    {
        var node:DialogNodeStructure = this.dialogList.last();
        
        if (node == null)
        {
            trace("I supposeed this should not be happening, but it's the end");
            return;
        }
        
        if (node.ReachTheEnd() == true)
        {
            trace(node.Name + " already reach the end of dialog script");
            
            this.dialogList.remove(node);
            
            return;
        }
        
        var content:Fast = node.GetCurrentContent();
        
        this._dialogManager.ProcessContentDialogData(content, this.DoDialogProcess);
        
        node.CurrentIndex++;
        //currentIndex++;
    }

    //dialogList store all the dialog node we're currently using, once it's empty, it's mean all the dialogs are done.
    private var dialogList:List<DialogNodeStructure>;
    private var defaultDialogNode:DialogNodeStructure;
    private var dialogNodes:Array<DialogNodeStructure> = new Array<DialogNodeStructure>();
    
	@:access(Xml)
    private function TestLoadDialogXml(data:Fast, sceneName:String, dialogNode:DialogNodeStructure) : Void 
    {
        //set name
        dialogNode.Name = U.xml_name(data.x);
        
        //First, doing the inject processing
        if (data.hasNode.inject)
        {
            while(data.hasNode.inject == true)
            {
                var inj_data = data.node.inject;
                var inj_name:String = U.xml_name(inj_data.x);
                var payload:Xml = U.xml(inj_name, "xml", false, Defines.ASSETS_DIALOG_PATH + sceneName + "/");
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
                dialogNode.ChoiceList.push(choice);
                
                //choiceList.push(choice);
                
                choice.rootData = choiceData;
                if (choiceData.hasNode.item)
                {
                    for (item in choiceData.nodes.item)
                    {
                        choice.items.push(item);
                    }
                }
            }
        }
        
        //process "data", working like a node, leaf in a tree, but not exactly
        if (data.hasNode.data)
        {
            for (blockData in data.nodes.data)
            {
                var node:DialogNodeStructure = new DialogNodeStructure();
                dialogNodes.push(node);
                
                //recursion
                this.TestLoadDialogXml(blockData, sceneName, node);
            }
        }
    }
    
    
    //{ Not very important functions
    
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
    //}
    
}
