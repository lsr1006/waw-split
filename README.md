# waw-split
Customizable in-game on-screen timer for CoD:WaW (Plutonium only) with automatic round history and splits.

![image](https://github.com/user-attachments/assets/1dbf021c-0201-4617-a50a-199113c05bc8)

### About
- Displays a variety of timer information on the in-game HUD (alternative to a third-party speedrun timer overlay like LiveSplit)
- Works for ALL stock World at War maps on Plutonium
- Complies with current ZWR world record rules: https://zwr.gg/rules/

### Features
- Displays the following information:
  - Total game time - measured from start of game (screen fade-in)
  - Per-round time - measured from start of round n to start of round n+1
  - History of most recent round times
  - User-defined round milestone/split times - measured from start of game to start of round n
- Fully automatic - All times are automatically started and split on round transitions
- Following parameters can be specified by the user with the variables at the top of the script:
  - Enable/disable back-speed fix
  - Enable/disable timer variations individually
  - Individual control over color and transparency of all elements
  - Global position (ex: can be moved to accommodate web-cams or other overlays on screen)
  - Number of round history times to show (shows past 4 rounds by default)
  - Specific rounds to show splits/milestoens (10, 30, 50, 70, 100 by default)

### How to use
- Read through the disclaimers below
- Download [waw-split.gsc](https://github.com/lsr1006/waw-split/releases/download/v1.1/waw-split.gsc)
- Place the file in the plutonium 'scripts' folder for the map you want to play:
  - `C:\users\YOUR_USERNAME\AppData\Local\Plutonium\storage\t4\raw\scripts\sp\MAP_NAME\waw-split.gsc`
    - Nach Der Untoten = `nazi_zombie_prototype`
    - Verruct = `nazi_zombie_asylum`
    - Shi No Numa = `nazi_zombie_sumpf`
    - Der Riese = `nazi_zombie_factory`
- If you have any existing scripts in this folder, remove them
- Play the map normally through Plutonium

### Disclaimers
- It is my intent for this to be compatable for world-record attempts for ZWR. Based on the rules, it should be. Please read the rules for yourself and use your own discretion.
- If you don't want to use the back-speed fix, it can be disabled at the top of the script. The backspeed client dvar will hold its state until changed again. If you want to stop using the script AND revert the backspeed fix, run the map once with "level.FIX_BACKSPEED = false" to restore the default values, then the script can be deleted. Or, use the console commands to revert the client dvars at any time.
- Default position is top left on 16:9 resolutions. Different aspect ratios or resoutions may need to adjust the coordinates. Try (0, 0) if you can't see the timer at all.
- Adding too many HUD elements can cause them to dissapear or glitch out. If you want to increase them beyond their default, do a test game to verify.
- I have tested this script solo on all stock WaW maps. I have not confirmed if this works co-op, or if it works for custom maps, but I believe it should.
- I have no reason to believe this would cause performance issues or crashes, but I have not tested it past round 30 myself. Use at your own risk for world-record attempts.
- Please report any problems and feel free to provide suggestions for improvements

### Screenshots
![image](https://github.com/user-attachments/assets/45c90196-bd33-4177-b848-5d1945c95739)
![image](https://github.com/user-attachments/assets/4fb6adef-7d84-4271-ae30-22150d7efae9)
![image](https://github.com/user-attachments/assets/1a8e5c44-3666-4ad9-a2bf-15dd497e8699)
![image](https://github.com/user-attachments/assets/95339bd0-99a4-4970-9eb6-4e84d1e3bab5)

