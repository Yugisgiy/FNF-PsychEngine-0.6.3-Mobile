package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxButton;
import flixel.text.FlxText;
import flixel.system.FlxAssets;
import flixel.graphics.FlxShader;
import flixel.input.mouse.FlxMouseEvent;
import flixel.util.FlxColor;

class MainMenuState extends MusicBeatSubState {
    
    private var background:FlxSprite;
    private var playButton:FlxButton;
    private var optionsButton:FlxButton;
    private var quitButton:FlxButton;
    private var menuTitle:FlxText;
    
    private var shader:FlxShader;
    
    override public function create():Void {
        super.create();
        
        // Set the background (Make sure to use Dead Air's theme background)
        background = new FlxSprite(0, 0);
        background.loadGraphic("assets/images/main/ohiogaming.png", true, 1280, 720);  // Adjust size as needed
        background.scrollFactor.set(0, 0);
        add(background);

        // Apply a custom shader to the background (eerie effect)
        shader = new FlxShader();
        shader.load("assets/shaders/dead_air_shader.frag");  // Ensure you have the shader file in the right location
        background.setShaders([shader]);
        
        // Menu Title
        menuTitle = new FlxText(FlxG.width / 2 - 100, 50, 200, "Dead Air");
        menuTitle.setFormat(null, 32, FlxColor.WHITE, "center");
        add(menuTitle);

        // Play Button
        playButton = new FlxButton(FlxG.width / 2 - 100, FlxG.height / 2 - 50, "Play", onPlayClick);
        playButton.setSize(200, 50);
        add(playButton);

        // Options Button
        optionsButton = new FlxButton(FlxG.width / 2 - 100, FlxG.height / 2 + 10, "Options", onOptionsClick);
        optionsButton.setSize(200, 50);
        add(optionsButton);
        
        // Quit Button
        quitButton = new FlxButton(FlxG.width / 2 - 100, FlxG.height / 2 + 70, "Quit", onQuitClick);
        quitButton.setSize(200, 50);
        add(quitButton);
        
        // Optional: Add some eerie background music
        FlxG.sound.play("assets/music/freakyMenu", 0.5, true);  // Ensure you have the correct path
        
    }
    
    // Button actions
    private function onPlayClick():Void {
        // Transition to the game state (implement this state)
        FlxG.switchState(new PlayState());
    }

    private function onOptionsClick():Void {
        // Transition to options menu (implement this state)
        FlxG.switchState(new OptionsState());
    }

    private function onQuitClick():Void {
        // Quit the game
        FlxG.quit();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        // Additional effects or input handling can go here
    }
}
