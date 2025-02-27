package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import flixel.addons.ui.FlxUI9SliceSprite;
import flash.geom.Rectangle;
import openfl.utils.Assets as OpenFlAssets;
import flixel.util.FlxTimer;
using StringTools;

class ChangedFreeplayState extends MusicBeatState
{
	//Character head icons for your songs
	var songsHeads:Array<Dynamic> = [
		['colin'],										//Week 1
		['puro'],										//Week 2
		['drk'],										//Week 3
		['face', 'face', 'tigershark', 'sdog', 'drk', 'drk'],	//Week 4
		['colin','puro','drk','drk','drk','face', 'colin']					//Week 5
	];

	var songCreator:Array<Dynamic> = [
		['TrustVVorthy'],																				//Week 1
		['TrustVVorthy'],																				//Week 2
		['TrustVVorthy'],																				//Week 3
		['TrustVVorthy', 'TrustVVorthy', 'TrustVVorthy', 'TrustVVorthy', 'TrustVVorthy'],				//Week 4
		['TrustVVorthy','TrustVVorthy','TrustVVorthy','TrustVVorthy','TrustVVorthy','TrustVVorthy']		//Week 5
	];
	var songs:Array<FreeplayState.SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var boxPos:Int = 1;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<FlxText>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	public static var coolColors:Array<Int> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var font = Paths.font("SourceHanSansK-Normal.ttf");
	var txtSize = 32;
	var border = 32;
	var onScreen = 11;

	var opSpace = 55;
	var opX = 80;
	var opY = 113;
	var selectbox:FlxUI9SliceSprite;
	var init = false;

	var curWacky:Array<String> = [];

	override function create()
	{

		curWacky = FlxG.random.getObject(getIntroTextShit());

		FlxG.camera.bgColor = 0xFF000000;
		if(!ClientPrefs.oldArt){
			songsHeads = [
				['new-colin'],											//Week 1
				['new-puro'],											//Week 2
				['new-drk'],											//Week 3
				['ballin', 'ballin', 'ballin', 'ballin', 'new-drk', 'new-drk'],	//Week 4
				['new-colin','new-puro','new-drk','new-drk','new-drk','ballin','ballin']			//Week 5
			];
		}
		//transIn = FlxTransitionableState.defaultTransIn;
		//transOut = FlxTransitionableState.defaultTransOut;

			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('jammin'));
			}
		 

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.songsNames.length) {
			#if !debug
			if (StoryMenuState.weekUnlocked[i])
			#end
				addWeek(WeekData.songsNames[i], i, songsHeads[i], songCreator[i]);
		}
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		// MENU BOX SHIT =============================
		var num = 6;
		var lineHeight = 100;
		var lineWidth = 430;

		var _slice:Array<Int> = [0+num, 0+num, 64-num, 64-num];
		var menubox1 = new FlxUI9SliceSprite(0, 0, Paths.image('changedMenuBoxResize'), new Rectangle(0, 0, 1280, lineHeight), _slice);
		var menubox2 = new FlxUI9SliceSprite(0, lineHeight, Paths.image('changedMenuBoxResize'), new Rectangle(0, 0, lineWidth, 720-lineHeight), _slice);
		var menubox3 = new FlxUI9SliceSprite(lineWidth, lineHeight, Paths.image('changedMenuBoxResize'), new Rectangle(0, 0, 1280-lineWidth, 720-lineHeight), _slice);
		add(menubox1);
		add(menubox2);
		add(menubox3);

		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var iconscale = 0.4;
			var iconOffset = opX-10;


			var txt:FlxText = new FlxText(opX, opY+(i*opSpace), 0, songs[i].songName, txtSize, true);
			txt.setFormat(font, txtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
			txt.borderSize = 2;
			txt.alignment = FlxTextAlign.LEFT;
			txt.updateHitbox();
			if(txt.text.contains('-')){
				txt.text = StringTools.replace(songs[i].songName, '-', ' ');
			}
			grpSongs.add(txt);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.scale.set(iconscale, iconscale);
			icon.sprTracker = txt;
			icon.menuIcon = true;
			icon.updateHitbox();
			icon.xOffset = -iconOffset;
			icon.yOffset = -8;

			iconArray.push(icon);
			add(icon);
		}
		
		var funnyText:FlxText = new FlxText(25, 32, curWacky[0], txtSize, true);
		funnyText.setFormat(font, txtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
		funnyText.borderSize = 2;
		funnyText.updateHitbox();
		add(funnyText);

		// ===================== selection box =====================
		var border2 = 6;
		var val2 = 2;
		selectbox = new FlxUI9SliceSprite(border2+val2/2, opY-6, Paths.image('changedSelectionBoxResize'), new Rectangle(0, 0, lineWidth-(border2+8), opSpace), _slice);
		selectbox.visible = true;
		add(selectbox);

		/*/ score text
		scoreText = new FlxText(, 5, 0, "", 32);
		scoreText.setFormat(font, txtSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
		scoreText.setFormat(font, 32, FlxColor.WHITE, RIGHT);*/


		changeSelection();
		super.create();
	}

	override function closeSubState() {
		changeSelection();
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, creator:String)
	{
		songs.push(new FreeplayState.SongMetadata(songName, weekNum, songCharacter, creator));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?creator:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		if (creator == null)
			creator = ['TrustVVorthy'];

		var num:Int = 0;
		var num2:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], creator[num2]);

			if (songCharacters.length != 1)
				num++;

			if (creator.length != 1)
				num2++;
		}
	}

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var up = controls.UI_UP;
		var down = controls.UI_DOWN;
		var upR = controls.UI_UP_R;
		var downR = controls.UI_DOWN_R;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;


		var motherfuckerBoolean = false;

		if(up && curSelected != 0){ 
			if (upP)
			{
				changeSelection(-1);
			}
		}
			
		if(down && curSelected != songs.length -1){
			if (downP)
			{
				changeSelection(1);
			}
		}



		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('CH_Cancel'));
			MusicBeatState.switchState(new ChangedMainMenuState());
		}

		if (accepted)
		{
			FlxG.sound.play(Paths.sound('CH_Load'));
			var songLowercase:String = songs[curSelected].songName.toLowerCase();
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
				poop = songLowercase;
				curDifficulty = 0;
				trace('Couldnt find file');
			}
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CURRENT WEEK: ' + WeekData.getCurrentWeekNumber());
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeSelection(change:Int = 0)
	{
		////////////// FIX THIS SHIT /////////////////////////////////////////////
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// fuck you past plague for coding this menu so shittily !!!!
		// dumbas
		
		FlxG.sound.play(Paths.sound('CH_Cursor'));
		var songshit:Array<FlxText> = grpSongs.members;
		var trackmove:Bool; // holy shit i wasted so much time when all i needed was a bool -Plague

		// move the box
		if((boxPos+change != onScreen+1 && change == 1) || (boxPos+change != 0 && change == -1)){
			selectbox.y += opSpace*change;
			boxPos += change;
			trackmove = false;
		}else{
			trackmove = true;
		}

		// move the songlist
		for(i in 0...songshit.length){
			if(trackmove == true){
				songshit[i].y += opSpace*-change;
				
				if(change == 1){
					songshit[curSelected-(onScreen-1)].visible = false;
					iconArray[curSelected-(onScreen-1)].visible = false;
				}
				if(change == -1){
					songshit[curSelected-1].visible = true;
					iconArray[curSelected-1].visible = true;
				}
			}
		}
		curSelected += change;
		trace(curSelected);

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;
	}
	
	function getIntroTextShit():Array<Array<String>>
		{
			var fullText:String = Assets.getText(Paths.txt('introText'));
	
			var firstArray:Array<String> = fullText.split('\n');
			var swagGoodArray:Array<Array<String>> = [];
	
			for (i in firstArray)
			{
				swagGoodArray.push(i.split('--'));
			}
	
			return swagGoodArray;
		}
}