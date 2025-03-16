#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

init()
{
           
	// ============================================================================================================
	// 		 _       __     _       __            _____ ____  __    __________
	// 		| |     / /___ | |     / /           / ___// __ \/ /   /  _/_  __/
	// 		| | /| / / __ `/ | /| / /  ______    \__ \/ /_/ / /    / /  / /   		WaW-Split (Version 1)
	// 		| |/ |/ / /_/ /| |/ |/ /  /_____/   ___/ / ____/ /____/ /  / /
	// 		|__/|__/\__,_/ |__/|__/            /____/_/   /_____/___/ /_/
	//
	//
	//		Customizable speedrun split timer for World at War (Plutonium) w/ optional backspeed fix
	//		Complies with ZWR world record rules: https://zwr.gg/rules/#section-21
	//
	// ============================================== TIMER SETTINGS  ============================================
	//
	//		WARNINGS:
	//			- The backspeed fix will carry over between games. If you want to revert the backspeed fix,
	//				run a map once with "level.FIX_BACKSPEED = false" to restore default values, or use commands
	// 			- Adjusting spacing drastically might cause overlapping elements
	//			- Adding too many HUD elements can cause them to dissapear or glitch out,
	//				Keep HISTORY_MAX_COUNT and MILESTONES at reasonable levels (<12 between both)
	//
	//		Adjust timer position with the X and Y coordinates
	//		Color values are (RED, GREEN, YELLOW) each with a value between 0.0 and 1.0
	//		Alpha values are between 0.0 and 1.0
	
	level.FIX_BACKSPEED = true;	// Disable this to revert the backspeed fix
	
	level.HUD_X_COORD = -100;		// Move the timer HUD on X axis (left=negative, right=positive)
	level.HUD_Y_COORD = 0;			// Move the timer HUD on Y axis (up=negative, down=positive)
	level.HUD_COL_SPACING = 70;		// Space between the label/value columns
	level.HUD_ROW_SPACING = 10;		// Space between the data rows
	
	level.GAME_TIME_COLOR = (1, 0, 0);
	level.GAME_TIME_ALPHA = 1;
	
	level.ROUND_TIME_HIDDEN = false;				// Hide the current round timer and round history
	level.ROUND_TIME_LABEL_COLOR = (1, 1, 1);
	level.ROUND_TIME_VALUE_COLOR = (1, 1, 1);
	level.ROUND_TIME_ALPHA = 1;
	
	level.HISTORY_HIDE_EMPTY = false;				// Keep history rows hidden until they are populated
	level.HISTORY_MAX_COUNT = 4;					// Max history to show for previous rounds (0 to hide)
	level.HISTORY_LABEL_COLOR = (0.6, 0.6, 0.6);	// WARNING: Don't set HISTORY_MAX_COUNT too high!
	level.HISTORY_VALUE_COLOR = (0.6, 0.6, 0.6);
	level.HISTORY_ALPHA = 0.9;
	level.HISTORY_LABEL_TEXT = "Round";
	level.HISTORY_LABEL_DELIMITER = ":";
													
	level.MILESTONES_HIDDEN = false;	// Hide the Round milestones section
	level.MILESTONES = [];				// Cumulative time will show on HUD upon reaching certain rounds
	level.MILESTONES[0] = 10;			// Usefull for world record attempts (30, 50, 70, 100)
	level.MILESTONES[1] = 30;			// WARNING: Don't add too many! keep [index] increasing by 1
	level.MILESTONES[2] = 50;
	level.MILESTONES[3] = 70;
	level.MILESTONES[4] = 100;
	level.MILESTONES_LABEL_COLOR = (0.4, 0.7, 0.4);
	level.MILESTONES_VALUE_COLOR = (0.4, 0.7, 0.4);
	level.MILESTONES_ALPHA = 0.9;
	level.MILESTONES_LABEL_TEXT = "Total";
	level.MILESTONES_LABEL_DELIMITER = ":";
	
	// ===========================================================================================================

	thread on_connect();
}

game_timer()
{
	hud = create_simple_hud( self );
	hud.foreground = true;
	hud.sort = 1;
	hud.hidewheninmenu = true;
	hud.alignX = "left";
	hud.alignY = "top";
	hud.x = level.HUD_X_COORD;
	hud.y = level.HUD_Y_COORD;
	hud.alpha = level.GAME_TIME_ALPHA;
	hud.color =  level.GAME_TIME_COLOR;
	hud.fontscale = 2;
	hud SetText("--:--");
	level waittill("round_transition");
	hud setTimerUp(0);
}

round_timer()
{
	label = create_simple_hud( self );
	label.foreground = true;
	label.sort = 1;
	label.hidewheninmenu = true;
	label.alignX = "left";
	label.alignY = "top";
	label.x = level.HUD_X_COORD;
	label.y = level.HUD_Y_COORD + (level.HUD_ROW_SPACING * 2);
	label.alpha = level.ROUND_TIME_ALPHA;
	label.color =  level.ROUND_TIME_LABEL_COLOR;
	label.fontscale = 1;
	label SetText("Round starting...");
	
	time = create_simple_hud( self );
	time.foreground = true;
	time.sort = 1;
	time.hidewheninmenu = true;
	time.alignX = "left";
	time.alignY = "top";
	time.x = level.HUD_X_COORD + level.HUD_COL_SPACING;
	time.y = level.HUD_Y_COORD + (level.HUD_ROW_SPACING * 2);
	time.alpha = level.ROUND_TIME_ALPHA;
	time.color =  level.ROUND_TIME_VALUE_COLOR;
	time.fontscale = 1;
	
	roundHistory = spawnStruct();
	level waittill("round_transition");
	init_round_history(roundHistory);
	
	for (;;)
	{
		currentRound = level.round_number;
		time setTimerUp(0);
		roundStart = GetTime() / 1000;
		label SetText(level.HISTORY_LABEL_TEXT + " " + currentRound + level.HISTORY_LABEL_DELIMITER);
		level waittill("round_transition");
		
		if (level.HISTORY_MAX_COUNT == 0) continue;

		roundEnd = GetTime() / 1000;
		roundDuration = format_seconds(roundEnd - roundStart);
		enqueue_round_history(roundHistory, currentRound, roundDuration);
		refresh_round_history_hud(roundHistory);
	}
}

milestone_timers()
{
	level waittill("round_transition");
	gameStart = GetTime() / 1000;
	milestonesHit = 0;
	
	if (level.ROUND_TIME_HIDDEN)
	{
		yCoord = level.HUD_Y_COORD + (level.HUD_ROW_SPACING * 2);
	} else {
		yCoord = level.HUD_Y_COORD + (level.HUD_ROW_SPACING * (level.HISTORY_MAX_COUNT + 4));
	}
	
	for (;;)
	{
		level waittill("round_transition");
		currentRound = level.round_number;
		isMilestone = false;
		
		for (i = 0; i < level.MILESTONES.size; i++)
		{
			if (level.MILESTONES[i] == currentRound)
			{
				isMilestone = true;
				break;
			}
		}
		
		if (!isMilestone) continue;
		milestonesHit++;
		elapsed = format_seconds((GetTime() / 1000) - gameStart);
		
		label = create_simple_hud( self );
		label.foreground = true;
		label.sort = 1;
		label.hidewheninmenu = true;
		label.alignX = "left";
		label.alignY = "top";
		label.x = level.HUD_X_COORD;
		label.y = yCoord;
		label.alpha = level.MILESTONES_ALPHA;
		label.color =  level.MILESTONES_LABEL_COLOR;
		label.fontscale = 1;
		label SetText(level.MILESTONES_LABEL_TEXT + " 1-" + currentRound + level.MILESTONES_LABEL_DELIMITER);
		
		time = create_simple_hud( self );
		time.foreground = true;
		time.sort = 1;
		time.hidewheninmenu = true;
		time.alignX = "left";
		time.alignY = "top";
		time.x = level.HUD_X_COORD + level.HUD_COL_SPACING;
		time.y = yCoord;
		time.alpha = level.MILESTONES_ALPHA;
		time.color =  level.MILESTONES_VALUE_COLOR;
		time.fontscale = 1;
		time SetText(elapsed);
		
		if (milestonesHit >= level.MILESTONES.size) return;
		yCoord = yCoord + level.HUD_ROW_SPACING;
	}
}

init_round_history(roundHistory)
{
	// Crude circular queue implementation to store limited round history
	roundHistory.queue = [];
	
	// Index starts at last position and becomes 0 on round 1
	roundHistory.indexOfNewest = level.HISTORY_MAX_COUNT - 1;
	if (roundHistory.queue < level.HISTORY_MAX_COUNT)
	{
		yCoord = level.HUD_Y_COORD + (level.HUD_ROW_SPACING * 3);
		for (i = 0; i < level.HISTORY_MAX_COUNT; i++)
		{
			label = create_simple_hud( self );
			label.foreground = true;
			label.sort = 1;
			label.hidewheninmenu = true;
			label.alignX = "left";
			label.alignY = "top";
			label.x = level.HUD_X_COORD;
			label.y = yCoord;
			label.alpha = level.HISTORY_ALPHA;
			label.color =  level.HISTORY_LABEL_COLOR;
			label.fontscale = 1;
			
			value = create_simple_hud( self );
			value.foreground = true;
			value.sort = 1;
			value.hidewheninmenu = true;
			value.alignX = "left";
			value.alignY = "top";
			value.x = level.HUD_X_COORD + level.HUD_COL_SPACING;
			value.y = yCoord;
			value.alpha = level.HISTORY_ALPHA;
			value.color =  level.HISTORY_VALUE_COLOR;
			value.fontscale = 1;
			
			if (!level.HISTORY_HIDE_EMPTY)
			{
				label SetText("...");
				value SetText("--:--");
			}
			
			roundData = spawnStruct();
			roundData.hudLabel = label;
			roundData.hudValue = value;
			roundHistory.queue[i] = roundData;
			yCoord = yCoord + level.HUD_ROW_SPACING;
		}
	}
}

enqueue_round_history(roundHistory, currentRound, roundDuration)
{
	if (roundHistory.indexOfNewest == level.HISTORY_MAX_COUNT - 1)
	{
		roundHistory.indexOfNewest = 0;
	} else {
		roundHistory.indexOfNewest++;
	}

	roundHistory.queue[roundHistory.indexOfNewest].hudLabel SetText(level.HISTORY_LABEL_TEXT + " " + currentRound + level.HISTORY_LABEL_DELIMITER);
	roundHistory.queue[roundHistory.indexOfNewest].hudValue SetText(roundDuration);
}

refresh_round_history_hud(roundHistory)
{
	if (roundHistory.queue.size <= 1) return;
	yCoord = level.HUD_Y_COORD + (level.HUD_ROW_SPACING * 3);
	updatedCount = 0;
	updateIndex = roundHistory.indexOfNewest;
	
	// Reposition hud elements into correct order
	while(updatedCount < level.HISTORY_MAX_COUNT) {
		roundHistory.queue[updateIndex].hudLabel.y = yCoord;
		roundHistory.queue[updateIndex].hudValue.y = yCoord;
		updatedCount++;
		yCoord = yCoord + level.HUD_ROW_SPACING;
		if (updateIndex == 0)
		{
			updateIndex = level.HISTORY_MAX_COUNT - 1;
		} else {
			updateIndex--;
		}
	}
}

format_seconds(secs)
{
	secs = int(secs);
    hrs = int(secs / 3600);
    mins = int((secs % 3600) / 60);
    secs = secs % 60;
    
    // Add leading zeros for formatting if necessary
    if (secs < 10) {
		secs = "0" + secs;
	}
    if (mins < 10 && hrs != 0) {
		mins = "0" + mins;
	}
    if (hrs > 0) {
        return hrs + ":" + mins + ":" + secs;
    } else {
        return mins + ":" + secs;
    }
}

patch_notifier()
{
	hud = create_simple_hud( self );
	hud.foreground = true;
	hud.sort = 1;
	hud.hidewheninmenu = true;
	hud.alignX = "center"; 
	hud.alignY = "bottom";
	hud.horzAlign = "center"; 
	hud.vertAlign = "bottom";
	hud.x = 0;
	hud.y = 0;
	hud.alpha = 0.5;
	hud.fontscale = 1;
	flag_wait("all_players_spawned");
	
	backspeedStatus = "";
	if (getdvarfloat("player_backSpeedScale") != 0.7 || getdvarfloat("player_strafeSpeedScale") != 0.8)
	{
		backspeedStatus = "+ backspeed ";
	}
	hud SetText("Custom timer " + backspeedStatus + "patch in use (WaW-Split v1)");
	wait(10);
	hud destroy();
}

// Not the best way to do this but it works for all maps and is accurate enough
round_monitor()
{
	for (;;) {
		roundStart = level.round_start_time;
		while(roundStart == level.round_start_time)
		{
			wait(0.25);
		}
		level notify("round_transition");
	}
}

on_connect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread on_player_spawned();
	}
}

on_player_spawned()
{
	level waittill("connected", player);
	
	// Custom timer functions
	self thread round_monitor();
	self thread game_timer();
	if (!level.ROUND_TIME_HIDDEN) self thread round_timer();
	if (!level.MILESTONES_HIDDEN) self thread milestone_timers();
	
	// Backspeed fix - (enforce the default values)
	self SetClientDvars("player_backSpeedScale", "0.7", "player_strafeSpeedScale", "0.8");
	if(level.FIX_BACKSPEED)
	{
		self SetClientDvars("player_backSpeedScale", "1", "player_strafeSpeedScale", "1");
	}

	self thread patch_notifier();
}
