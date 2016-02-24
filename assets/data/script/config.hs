trace("helloworld");
FlxG.log.add("log: helloworld, hell yeah");

function testCreateFunction()
{
    trace("testCreateFunction");
    FlxG.log.add("testCreateFunction");
}

function testUpdateFunction(elapsed)
{
    if (FlxG.keys.pressed.D)
    {
        player.x += 5;
    }
    
    if (FlxG.keys.pressed.A)
    {
        player.x -= 5;
    }
    
    if (FlxG.keys.pressed.W)
    {
        player.y -= 5;
    }
    
    if (FlxG.keys.pressed.S)
    {
        player.y += 5;
    }
}

