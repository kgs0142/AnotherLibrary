
var effect;

function PlayDrama()
{
    //I guess I will play lot of drama by delay or something.

    trace("Remove UI and play drama ...barabara");

    this.RemoveAllElements();

    var actor = new FlxSprite(0, 0, AssetPaths.RogueBear__png);

    effect = new FlxEffectSprite(actor);
    effect.y = 50;

    var outline = new FlxOutlineEffect(0xFFFF0000, 1);
    var trail = new FlxTrailEffect(effect, 10, 0.5, 8);

    effect.effects = [outline, trail];

    FlxTween.tween(effect, {x: 200}, 2, {onComplete: Tween01_Done});

    FlxG.state.add(effect);
}

function Tween01_Done()
{
    FlxG.state.remove(effect);
    
    trace("Complete, what a good show");

    this.DoNextDialogProcess();
}