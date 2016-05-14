package core.ui;

import flash.media.Sound;
import flixel.addons.text.FlxTypeText;
import flixel.FlxG;
import flixel.system.FlxAssets;

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
    
    public function new(X:Float, Y:Float, Width:Int, Text:String, Size:Int=8, EmbeddedFont:Bool=true) 
    {
        super(X, Y, Width, Text, Size, EmbeddedFont);
        
        this.m_DelayChars = [];
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
    
    private function SetDefaultSetting() : Void 
    {
        this.delay = 0.1;
		this.eraseDelay = 0.2;
        this.antialiasing = false;
		//this.showCursor = true;
		this.cursorBlinkSpeed = 1.0;
		//this.prefix = "C:/HAXE/FLIXEL/";
		//this.autoErase = true;
		this.waitTime = 2.0;
		this.setTypingVariation(0.75, true);
		this.color = 0x8811EE11;
		this.skipKeys = ["SPACE"];
        this.useDefaultSound = false;
        this.sounds = [FlxG.sound.load(FlxAssets.getSound(AssetPaths.defaultTypetext__ogg.ExcludeExt()))];
        
        //My custom parameters
        this.m_DelayChars = [","];
    }

    public function SetDelayCharFactor(factor:Float) : Void 
    {
        this.m_fDelayCharFactor = factor;
    }
    
    override public function resetText(Text:String) : Void 
    {
        super.resetText(Text);
        
        this.DoCustomCodeProcessOnFinalText();
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