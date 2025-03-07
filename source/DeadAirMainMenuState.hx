package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxState;

class DeadAirMainMenuState extends MusicBeatState
{
    var title:FlxText;
    var glitchEffect:FlxSprite;
    var menuItems:Array<FlxText> = [];
    var selectedItem:Int = 0;

    override public function create():Void
    {
        super.create();

        // Dark and unsettling background
        FlxG.cameras.bgColor = FlxColor.fromRGB(5, 5, 5);

        // Main title (Dead Air aesthetic)
        title = new FlxText(0, FlxG.height * 0.2, FlxG.width, "DEAD AIR");
        title.setFormat("VCR OSD Mono", 70, FlxColor.WHITE, CENTER);
        title.alpha = 0.9;
        add(title);

        // Glitch effect (just a simple visual placeholder for now)
        glitchEffect = new FlxSprite().loadGraphic(Paths.image('glitch_effect'));
        glitchEffect.setGraphicSize(Std.int(FlxG.width * 0.8));
        glitchEffect.screenCenter();
        glitchEffect.alpha = 0.4;
        add(glitchEffect);

        // Menu options
        addMenuItem("Story Mode");
        addMenuItem("Freeplay");
        addMenuItem("Options");

        updateSelection();

        // Glitchy tween effect for title
        FlxTween.tween(title, {x: title.x + 5}, 0.1, {type: FlxTween.PINGPONG});
        FlxTween.tween(glitchEffect, {alpha: 0.1}, 0.3, {type: FlxTween.PINGPONG});
    }

    function addMenuItem(text:String):Void
    {
        var item = new FlxText(0, FlxG.height * (0.4 + (menuItems.length * 0.1)), FlxG.width, text);
        item.setFormat("VCR OSD Mono", 40, FlxColor.GRAY, CENTER);
        item.ID = menuItems.length;
        menuItems.push(item);
        add(item);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (controls.UP_P)
        {
            selectedItem = (selectedItem - 1 + menuItems.length) % menuItems.length;
            updateSelection();
        }

        if (controls.DOWN_P)
        {
            selectedItem = (selectedItem + 1) % menuItems.length;
            updateSelection();
        }

        if (controls.ACCEPT)
        {
            switch (selectedItem)
            {
                case 0: FlxG.switchState(new StoryMenuState());
                case 1: FlxG.switchState(new FreeplayState());
                case 2: FlxG.switchState(new OptionsState());
            }
        }
    }

    function updateSelection():Void
    {
        for (i in 0...menuItems.length)
        {
            menuItems[i].color = (i == selectedItem) ? FlxColor.WHITE : FlxColor.GRAY;
        }
    }
}
