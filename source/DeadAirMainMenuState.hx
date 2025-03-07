package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxText;
import flixel.util.FlxColor;
import flixel.system.input.Mouse;
import flixel.FlxButton;
import flixel.FlxSound;

class MainMenuState extends FlxState
{
    var bg:FlxSprite;
    var title:FlxText;
    var startButton:FlxButton;
    var hoverSound:FlxSound;
    var clickSound:FlxSound;

    override public function create():Void
    {
        super.create();

        // Background setup (Dead Air's dark atmosphere)
        bg = new FlxSprite(0, 0);
        bg.loadGraphic("assets/images/deadAir_background.png", true, 1280, 720);
        add(bg);

        // Title text setup
        title = new FlxText(0, 50, FlxG.width, "Dead Air");
        title.setFormat(null, 64, FlxColor.WHITE, "center");
        add(title);

        // Start button setup
        startButton = new FlxButton(FlxG.width / 2 - 100, FlxG.height / 2 + 100, "Start", onStartPressed);
        startButton.onMouseOver.add(onHoverStartButton);
        startButton.onMouseOut.add(onHoverEndStartButton);
        startButton.onClick.add(onClickStartButton);
        add(startButton);

        // Load sound effects
        hoverSound = FlxG.loadSound("assets/sounds/hoverSound.mp3");
        clickSound = FlxG.loadSound("assets/sounds/clickSound.mp3");
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // You can update things here, like animating the background or menu elements if needed.
    }

    function onStartPressed():Void
    {
        // Transition to the gameplay state, as would be done in the original Dead Air mod
        FlxG.switchState(new PlayState());
    }

    function onHoverStartButton():Void
    {
        // Play hover sound effect when the mouse hovers over the start button
        hoverSound.play();
        startButton.color = FlxColor.getColor(255, 0, 0); // Change the button color on hover
    }

    function onHoverEndStartButton():Void
    {
        // Reset the color when the mouse leaves the start button
        startButton.color = FlxColor.getColor(255, 255, 255); // Reset to white
    }

    function onClickStartButton():Void
    {
        // Play click sound effect when the start button is clicked
        clickSound.play();
    }
}
