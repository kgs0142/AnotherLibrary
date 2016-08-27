package core.ui;

import core.define.Defines;
import flash.media.Sound;
import flixel.addons.text.FlxTypeText;
import flixel.addons.ui.FlxUIRegion;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxAssets;
import haxe.Constraints.FlatEnum;
import haxe.xml.Fast;

using core.util.CustomExtension;

/**
 * ...
 * @author User
 */
class UIDialogText extends FlxTypeText
{
    //this is the only custom code ran into my mind currently.
    //it's working like this in text script => "::sound:assets/sounds/hello:hello."
    private static inline var DIALOG_AUDIO_CODE:String = "::sound";
    private static inline var BLOCK_CHAR:String = ":";
    
    //delay char
    private var m_DelayChars:Array<String>;
    private var m_iPreCharIndex:Int = -1;
    private var m_iCurCharIndex:Int = -1;
    private var m_fDelayCharFactor:Float = 5.0;
    
    //dialog audio
    private var m_mapDialogPos:Map<Int, String>;
    
    public var m_confirmKeys:Array<FlxKey> = [];
    
    private var m_funcCompleteCallback:Void->Void;
    private var m_bTypeComplete:Bool;
    
    private var m_bSysAutoConfirm:Bool;
    
    public function new(X:Float = 0, Y:Float = 0, Width:Int = 0, Text:String = "", Size:Int=8, EmbeddedFont:Bool=true) 
    {
        super(X, Y, Width, Text, Size, EmbeddedFont);
        
        this.m_DelayChars = [];
        this.m_bTypeComplete = false;
        this.m_bSysAutoConfirm = false;
        this.m_mapDialogPos = new Map<Int, String>();
        
        this.DoCustomCodeProcessOnFinalText();
        
        this.SetDefaultSetting();
    }
    
    override public function destroy() : Void 
    {
        super.destroy();
        
        this.m_mapDialogPos = null;
    }
    
    override public function update(elapsed:Float):Void 
    {
        //Custom skip and complete process-----------------------------------------------

        //System auto confirm
        if (m_bTypeComplete == true && m_bSysAutoConfirm == true)
        {
            if (this.m_funcCompleteCallback != null)
            {
                var funcTemp:Void->Void = this.m_funcCompleteCallback;
                this.m_funcCompleteCallback = null;
                
                funcTemp();
                
                return;
            }
        }
        
        #if !FLX_NO_KEYBOARD
        
        if (m_bTypeComplete == true && FlxG.keys.anyJustPressed(m_confirmKeys))
        {
            if (this.m_funcCompleteCallback != null)
            {
                var funcTemp:Void->Void = this.m_funcCompleteCallback;
                this.m_funcCompleteCallback = null;
                
                funcTemp();
                
                return;
            }
        }
        
		#end
        
        if (FlxG.mouse.justPressed == true && m_bSysAutoConfirm == false)
        {
            skip();
        }
        
        if (m_bTypeComplete == true && FlxG.mouse.justPressed == true)
        {
            if (this.m_funcCompleteCallback != null)
            {
                var funcTemp:Void->Void = this.m_funcCompleteCallback;
                this.m_funcCompleteCallback = null;
                funcTemp();
                
                return;
                
            }
        }
        
        //------------------------------------------------------------------------------
        
        super.update(elapsed);

        //Delay chars process.
        this.m_iCurCharIndex = this._length;
        if (this.m_iPreCharIndex == this.m_iCurCharIndex)
        {
            return;
        }
        this.m_iPreCharIndex = this.m_iCurCharIndex;

        //Custom code process
        this.DoCodeProcess(this.m_iCurCharIndex);
        
        //Delay Char process-----------------------------------------------------------------------
        var preUpdateCharIdx:Int = -1;
        preUpdateCharIdx = (_typing == true) ? this._length - 1 : preUpdateCharIdx;
        preUpdateCharIdx = (_erasing == true) ? this._length + 1 : preUpdateCharIdx;
        
        if (preUpdateCharIdx < 0 || preUpdateCharIdx >= this._finalText.length)
        {
            return;
        }
        
        var curChar:String = this._finalText.charAt(preUpdateCharIdx);
        if (this.m_DelayChars.indexOf(curChar) != -1)
        {
            _timer = -delay * FlxG.random.float(0.5, 1) * this.m_fDelayCharFactor;
        }
    }
    
    public function SetDefaultSetting() : Void 
    {
        this.delay = 0.05;
        this.size = 13;
		this.eraseDelay = 0.2;
        this.antialiasing = true;
		//this.showCursor = true;
		this.cursorBlinkSpeed = 1.0;
		//this.prefix = "C:/HAXE/FLIXEL/";
		//this.autoErase = true;
		this.waitTime = 2.0;
		this.setTypingVariation(0.75, true);
		this.color = 0xFF359F50;
		this.skipKeys = ["X", "SPACE"];
        this.m_confirmKeys = ["Z"];
        this.useDefaultSound = false;
        this.m_bSysAutoConfirm = false;
        this.sounds = [FlxG.sound.load(FlxAssets.getSound(AssetPaths.defaultTypetext__ogg.ExcludeExt()))];
        //this.sounds = [FlxG.sound.load(FlxAssets.getSound(AssetPaths.defaultTypetext__ogg.ExcludeExt())), 
                       //FlxG.sound.load(FlxAssets.getSound(AssetPaths.Blip_Select3__ogg.ExcludeExt())),
                       //FlxG.sound.load(FlxAssets.getSound(AssetPaths.Blip_Select4__ogg.ExcludeExt()))];
        
        //My custom parameters
        this.m_DelayChars = [",", ".", "-", "*", "?", "!"];
    }

    public function SetDelayCharFactor(factor:Float) : Void 
    {
        this.m_fDelayCharFactor = factor;
    }

	@:access(Xml)
    public function SetData(region:FlxUIRegion, content:Fast):Void 
    {
        this.x = region.x;
        this.y = region.y;
        //Silly
        //this.width = region.width;
        this.fieldWidth = region.width;
        
        //{ Some parameters
        var str:String = flixel.addons.ui.U.xml_str(content.x, "delay");
        if (str != "") { this.delay = Std.parseFloat(str); }
        
        str = flixel.addons.ui.U.xml_str(content.x, "typing_vary");
        if (str != "") { this.setTypingVariation(Std.parseFloat(str), true); }
        
        str = flixel.addons.ui.U.xml_str(content.x, "typing_snd");
        if (str != "") 
        {
            var nameWoExt:String = Defines.ASSETS_TYPING_SOUND_PATH + str;
            this.sounds = [FlxG.sound.load(FlxAssets.getSound(nameWoExt))];
        }
        
        //This is tricky, system will control this dialog, and auto go to next dialog.
        str = flixel.addons.ui.U.xml_str(content.x, "sys_ctrl");
        if (str != "" || str == "true")
        {
            this.skipKeys = [];
            this.m_confirmKeys = [];
            this.m_bSysAutoConfirm = true;
        }
        
        //}
        
        var txtContent:String = flixel.addons.ui.U.xml_str(content.x, "text");
        
        this.resetText(txtContent);
    }
    
    override public function resetText(Text:String) : Void 
    {
        super.resetText(Text);
        
        this.DoCustomCodeProcessOnFinalText();
    }
    
    override public function start(?Delay:Float, ForceRestart:Bool = false, AutoErase:Bool = false, ?SkipKeys:Array<FlxKey>, ?Callback:Void -> Void):Void 
    {
        this.m_bTypeComplete = false;

        if (Callback != null)
        {
            this.m_funcCompleteCallback = Callback;
        }
        
        super.start(Delay, ForceRestart, AutoErase, SkipKeys, this.SetTypeCompleteFlag);
    }
    
    private function SetTypeCompleteFlag() : Void 
    {
        this.m_bTypeComplete = true;
    }
    
    private function DoCustomCodeProcessOnFinalText() : Void 
    {
        var index:Int = _finalText.indexOf(DIALOG_AUDIO_CODE);
        while (index != -1) 
        {
            var startPos:Int = index + DIALOG_AUDIO_CODE.length + 1;
            var endPos:Int = _finalText.indexOf(BLOCK_CHAR, startPos);
            
            var codeContent:String = _finalText.substring(startPos, endPos);
            
            //set to map.
            this.m_mapDialogPos.set(index, codeContent);
            
            //combine the text
            var headPart:String = _finalText.substring(0, index);
            var restPart:String = _finalText.substring(endPos + 1);
            
            _finalText = headPart + restPart;
            
            //trace("index: " + index);
            //trace("codeContent: " + codeContent);
            //trace("_finalText: " + _finalText);
            
            index = _finalText.indexOf(DIALOG_AUDIO_CODE);
        }
    }
    
    private function DoCodeProcess(charIndex:Int) : Void 
    {
        if (this.m_mapDialogPos.exists(charIndex) == false)
        {
            return;
        }
        
        //Do Dialog_Audio code process
        var codeContent:String = this.m_mapDialogPos.get(charIndex);
        codeContent = codeContent.ExcludeExt();
        
        //Play sound
        var snd:Sound = FlxAssets.getSound(codeContent);
        
        FlxG.sound.play(snd);
        //FlxG.sound.load(codeContent).play();
    }
}