package;

import flixel.math.FlxRect;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.addons.ui.FlxUI9SliceSprite;
import flash.geom.Rectangle;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
import flixel.input.keyboard.FlxKey;
import openfl.Assets;
import Achievements;

using StringTools;

class ChangedMainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.3.1'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['NEW LIFE', 'OLD MEMORIES', 'OPTIONS', 'CREDITS', #if desktop 'GIVE UP' #end];

	var font = Paths.font("SourceHanSansK-Normal.ttf");
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var optionPos:Int = 0;
	var optionNumber:Int = 0;
	var menubox:FlxUI9SliceSprite;
	var selectbox:FlxUI9SliceSprite;
	var tweenWidth:Float;
	var logoBl:BGSprite;
	var sadcolin:BGSprite;
	var selected:Bool = false;

	var txtGroup:FlxTypedGroup<FlxText>;

	var opX = 0;
	var opY = 100;
	public var opSpace = 40;

	var txtSize = 32;
	var boxWidth = 275;
	var border = 32;
	var startbox:Bool = false;
	var lerpfunny:Float = 0;
	var lerpfunny2:Float = 0;
	
	override function create()
	{

		optionNumber = optionShit.length;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		if(FlxG.sound.music == null) {
			FlxG.sound.playMusic(Paths.music('jammin'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}
		Conductor.changeBPM(270); //280


		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		PlayerSettings.init();
		ClientPrefs.loadPrefs();
		Highscore.load();

		
		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		//transIn = FlxTransitionableState.defaultTransIn;
		//transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		logoBl = new BGSprite('changedlogobumpinBlack', 600, 20, 0, 0, ['ChangedLogoFinal']);
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.scale.set(0.7, 0.7);
		logoBl.dance(true);
		logoBl.updateHitbox();
		add(logoBl);

		//var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// TEXT SHITTTTTTT //////////////////////////////////////////////////////////////////////////
		txtGroup = new FlxTypedGroup<FlxText>();
		tweenWidth = boxWidth;

		for(i in 0...optionShit.length){
			var txt:FlxText = new FlxText(opX, opY+(i*opSpace), 0, "", 6, true);
			txt.setFormat(font, txtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
			txt.borderSize = 2;
			txt.alignment = FlxTextAlign.CENTER;
			txt.text = optionShit[i];
			txt.x -= txt.width/2;
			txt.updateHitbox();
			txtGroup.add(txt);
		}
		txtGroup.visible = false;

		// LE BOX ///////////////////////////////////////////////////////////////////////////////////////////////
		var num = 6;
		var _slice:Array<Int> = [0+num, 0+num, 64-num, 64-num];

		var mbrect:Rectangle = new Rectangle(0, 0, boxWidth, 1);
		menubox = new FlxUI9SliceSprite(0, 0, Paths.image('changedMenuBoxResize'), mbrect, _slice);
		menubox.setPosition(opX, (opY-(border/2)));
		menubox.x -= menubox.width/2;
		//var pnt:FlxPoint = new FlxPoint(0, menubox.y+((border+(optionShit.length*opSpace))/2));
		//menubox.resize_point = pnt;
		add(menubox);
		add(txtGroup);

		// selection box
		selectbox = new FlxUI9SliceSprite(opX, opY, Paths.image('changedSelectionBoxResize'), new Rectangle(0, 0, boxWidth-16, opSpace), _slice);
		selectbox.x -= selectbox.width/2;
		selectbox.visible = false;
		add(selectbox);

		// TIMER SHITTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
		new FlxTimer().start(1, function(tmr:FlxTimer){
			startbox = true;
		});

		new FlxTimer().start(1.2, function(tmr:FlxTimer){
			txtGroup.visible = true;
			selectbox.visible = true;
		});

		lerpfunny2 = (opY-(border/2))*2.2;
		
		sadcolin = new BGSprite("colinsadd", 0, -300);
		sadcolin.scale.set(0.6,0.6);
		sadcolin.updateHitbox();
		sadcolin.x -= sadcolin.width/2;
		sadcolin.visible = false;
		add(sadcolin);

		//easter egg
		

		// NG.core.calls.event.logEvent('swag').send();
		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));



		// handle input shit
		var input = 0;
		if(startbox == true && lerpfunny != border+(optionShit.length*opSpace)){
			lerpfunny = Math.round(FlxMath.lerp(lerpfunny, border+(optionShit.length*opSpace), 0.3));
			lerpfunny2 = Math.round(FlxMath.lerp(lerpfunny2, opY-(border/2), 0.3));
			menubox.y = lerpfunny2;
			menubox.resize(tweenWidth, lerpfunny);
		}

		if(txtGroup.visible == true && !selected){
			if(controls.UI_UP_P){
				input = -1;
				FlxG.sound.play(Paths.sound('CH_Cursor'));
			}
			if(controls.UI_DOWN_P){
				input = 1;
				FlxG.sound.play(Paths.sound('CH_Cursor'));
			}
		}

		if(optionPos+input == -1){
			optionPos = optionNumber-1;
		}else if(optionPos+input == optionNumber){
			optionPos = 0;
		}else{
			optionPos += input;
		}
		selectbox.y = 100+opSpace*optionPos;

		if (controls.ACCEPT){
			selected = true;
			var choice = optionShit[optionPos];
			FlxG.sound.play(Paths.sound('CH_Decision'));

			switch(choice){
				case 'NEW LIFE':
					MusicBeatState.switchState(new StoryMenuState());
				case 'OLD MEMORIES':
					MusicBeatState.switchState(new ChangedFreeplayState());
				case 'OPTIONS':
					MusicBeatState.switchState(new OptionsState());
				case 'CREDITS':
					MusicBeatState.switchState(new CreditsState());
				#if desktop
				case 'GIVE UP':
				var sadcolinchance:Int = FlxG.random.int(1,5);

				if(sadcolinchance == 5){
					sadcolin.visible = true;
					FlxG.sound.play(Paths.sound('VineBoom'));
					FlxTween.tween(sadcolin, {alpha: 0}, 0.6, {ease: FlxEase.sineIn});
				}

				new FlxTimer().start(0.5, function(tmr:FlxTimer){
					Sys.exit(0);
				});
				#end
			}
		}

		super.update(elapsed);
	}
	override function beatHit()
		{
			super.beatHit();
			if(curBeat % 2 == 0) {
				if(logoBl != null) 
					logoBl.dance(true);
			}
		}
}