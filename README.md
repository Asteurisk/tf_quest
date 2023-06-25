TF_Quest is a VScript mod that gives players the ability to complete player-created quests alone or with friends.

## Installation
Download the latest release .zip file.  Extract the .zip file to your "tf/scripts/vscripts" directory.  If the directory "vscripts" does not exist, you will need to create it.

## Usage

### Starting TF_Quest

**Listen Server**: If you are hosting a local server, type the command "script_execute tf_quest/main" into the console to enable TF_Quest.

**Dedicated Server**: If you are hosting a dedicated server, ensure you have the proper permission to run the "script_execute" command on the server, then type the command "script_execute tf_quest/main" or "rcon script_execute tf_quest/main"  into the console to enable TF_Quest.

### Adding Quests

By default, no quests are loaded when TF_Quest starts.  To load a quest, ensure that a quest script file is placed within the "tf_quest/quests" directory.  Then, open the console and use the command "script AddQuestFromFile('QUESTNAME.nut')" to add the quest.  You can also use "script AddQuestFromFiles(['QUESTNAME.nut', 'QUESTNAME2.nut', 'QUESTNAME3.nut'])" command to add multiple quests in one command.

You can automate this process when the map starts by placing the command inside a ".cfg" file.  For a **Listen Server**, put the command inside "listenserver.cfg", or for a **Dedicated Server**, put the command inside "server.cfg".

#### TF_Quest (Quest Pack)

In TF_Quest, there is a directory within "quests" that includes many example quests that you can use.  To use a quest, simply drag the ".nut" file to the "tf_quest/quests" directory and use the "script AddQuestFromFile("QUESTNAME.nut")" command in-game to load the quest.

### Compatibility with other VScripts

At this time, TF_Quest will not play well with other VScripts, this is because TF_Quest makes extremely heavy use of hooks (or events).  In Team Fortress 2, when a hook is used in a VScript, it overwrites the code that other VScripts use for the same hooks.  Getting other VScripts to be compatible with TF_Quest may require some knowledge of Squirrel programming language and VScripting.  If you are unfamiliar with either of these, you may want to use TF_Quest by itself on your server.

## Chat Commands

### Quest Commands
These commands allow players to start, stop, and list quests, as well as viewing their current objectives.

| Commands | Parameters | Description |
|----------|-------------|------------|
| !ListQuests | | Players can use this command to view all available quests |
| !StartQuest | QuestName | Players can start a quest that has been added by using this command and specifying the name of the quest |
| !RemoveQuest | QuestName | Players can stop a quest that they have started by using this command and specifying the name of the quest |
| !ShowObjectives | | Players can use this command to view all objectives they must complete |

### Party Commands
These commands allow players to work together to complete quests.  All players in a party get the same quest.

| Commands | Parameters | Description |
|----------|-------------|------------|
| !StartParty | | Players can create a new party by using this command |
| !JoinParty | UserName | Players can join another player's party by using this command and specifying ther username of the player |
| !LeaveParty | | Players can leave their current party by using this command |
| !Accept | UserName | Players can use this command when another player requests to join their party using the **!JoinParty** command |

### Miscellaneous Commands
These commands allow players to enable or disable various settings.

| Commands | Parameters | Description |
|----------|-------------|------------|
| !ToggleSounds | | Players can enable or disable the sounds that are played by the TF_Quest script |
| !ToggleHUD | | Players can enable or disable the Quest progress and objectives HUD element |
| !ToggleChat | | Players can enable or disable the quest objectives chat-message element |

## Creating Quests
Quest scripts are stored in .nut files, just like the TF_Quest VScript files.  If you intend to use your Quest script, ensure it is placed within the "tf_quest/quests" directory.  Many example quests exist in the "tf_quest/quests/TF_Quest Pack - Example Quests" directory.  Feel free to use or modify these quests however you like!

#### Example Quest Script
Our quest is called **My Quest**, and has the description **This is my Quest!** It is currently running in "contracker" mode which means that all points gained from the objectives will count toward a single goal. (Usually 100 points.)

Our mission is called **My Mission** and has a description of **This is my Mission!** Currently, the mission name and description are not used, but this may change in the future, so it's best to populate the data appropriately.

We then have three objectives, called **My Primary Objective**, **My First Bonus Objective**, and **My Second Bonus Objective**.  When the player starts this quest, they will be given these three objectives.  Each objective has an event that must occur to gain points for that objective.  For example, **My Primary Objective** requires that the player must kill another player to get points.  The amount of points they will be awarded is defined in ```objective_award```, and the total amount of times the player can get points for that objective is defined in ```objective_target```.

*Note: ```objective_points``` is used to set the amount of points the objective starts with, it's very uncommonly used.*
```
local quest = {
	quest_name = "My Quest"
	quest_desc = "This is my Quest!"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "My Mission"
		mission_desc = "This is my Mission!"
		mission_objectives =
		[
			{
				objective_name = "My Primary Objective"
				objective_desc = "Kill enemies"
				objective_points = 0
				objective_award = 1
				objective_target = 100
				objective_type = "KILL_PLAYER"
				objective_flags = []
			},
			{
				objective_name = "My First Bonus Objective"
				objective_desc = "Capture enemy Control Points"
				objective_points = 0
				objective_award = 5
				objective_target = 10
				objective_type = "CAPTURE_POINT"
				objective_flags = []
			},
			{
				objective_name = "My Second Bonus Objective"
				objective_desc = "Defend your Control Point"
				objective_points = 0
				objective_award = 5
				objective_target = 5
				objective_type = "KILL_CAPPER"
				objective_flags = []
			}
		]
	}
}

AddQuest(quest)
```
To use this quest in TF_Quest, we need to call the function ```AddQuest(quest)``` and add our table as the parameter.

#### Contracker quests VS Quest quests
In TF_Quest, a quest can run in one of two modes, either Contracker or Quest mode.  In Contracker mode, denoted as ```"contracker"```, all objectives give points to the main goal.  If a bonus objective has been completed, it will no longer add points to the main goal.  In Quest mode, denoted as ```"quest"```, objectives are completed independently of one another.

#### Objective Events

| Event | Description |
|-------|-------------|
| GET_POINTS | A player has gained a point |
| KILL_PLAYER | A player has killed another player |
| KILL_PLAYER_ASSIST | A player has assisted in killing another player |
| KILL_ENVIRONMENTAL | A player caused another player to die to the environment |
| KILL_CAPPER | A player has killed another player that was capturing a control point |
| SURVIVE_KILL | A player evaded death with the Razorback |
| DOMINATE_PLAYER | A player has dominated another player |
| STUN_PLAYER | A player has stunned another player |
| DAMAGE_PLAYER | A player has damaged another player |
| DAMAGE_BOSS | A player has damaged a boss NPC |
| PREVENT_DAMAGE_MEDISHIELD | A player used their medigun shield to deflect damage (MvM) |
| HEAL_PLAYER | A player healed to their patient |
| HEAL_BUILDABLE | A player healed their building |
| REVIVE_PLAYER | A player revived another player |
| IGNITE_PLAYER | A player has ignited another player |
| EXTINGUISH_PLAYER | A player has extinguished another player |
| TELEPORT_PLAYER | A player took another player's teleporter |
| INVUL_PLAYER | A player became ubered |
| SHARE_CANTEEN | A player shared their canteen with another player |
| BUILD_BUILDABLE | A player has built a building |
| UPGRADE_BUILDABLE | A player has upgraded a building |
| UPGRADE_BUILDABLE_ASSIST | A player has upgraded another player's building |
| DESTROY_BUILDABLE | A player has destroyed a building |
| DESTROY_BUILDABLE_ASSIST | A player has assisted destroying a building |
| DESTROY_RAZORBACK | A player has broken the Razorback off another player |
| DESTROY_TANK | A team of players have destroyed a tank
| SAPPED_BUILDABLE | A player's sapper destroyed a buildable |
| RESET_BOMB_DEPLOY | A player has prevented the bomb from being deployed (MvM) |
| WIN_GAME | A team of players have won the game |
| WIN_WAVE | A team of players have completed a wave (MvM) |
| DEFEND_FLAG | A player has killed another player who was carrying the intelligence |
| DEFEND_POINT | A player has defended the control point from another player |
| DEFEND_OBJECTIVE | A player has either defended their intelligence or their control point |
| PICKUP_FLAG | A player has picked up the enemy's intelligence |
| PICKUP_CRUMPKIN | A player has picked up a crit-pumpkin |
| PICKUP_GIFT | A player has picked up a christmas gift |
| PICKUP_MONEY | A player has picked up currency (MvM) |
| CAPTURE_FLAG | A player has captured the enemy's intelligence |
| CAPTURE_POINT | A player has captured a control point |
| CAPTURE_OBJECTIVE | A player has either captured the enemy's intelligence or a control point |

#### Objective Flags
**NOTE!** ```int teamNum``` refers to the following values: 0 = Friendly, 1 = Enemy, 2 = Self

| Flag | Description | Value |
|------|-------------|-------|
| PLAYER_CLASS | A player's current class | [int teamNum, int classNum] *or* [int teamNum, [int classNum, int classNum, ...]] |
| PLAYER_TEAM | A player's current team | [int teamNum, int gameTeam] |
| PLAYER_BUTTONS | A player's currently held buttons | [int teamNum, int FButtons] |
| PLAYER_WEAPON | Weapon used to perform action (i.e. killing player) | [int teamNum, string weaponName] *or* [int teamNum, [string weaponName, string weaponName, ...]] |
| PLAYER_BUILDABLE | Buildable used to perform action (i.e. killing player) | [int teamNum, string className] *or* [int teamNum, [string className, string className, ...]] |
| PLAYER_INCOND | A player must be in this condition | [int teamNum, int ETFCond] |
| PLAYER_HASITEM | A player must be holding an item | [int teamNum]
| PLAYER_AIRBORNE_EXPLOSION | A player is currently airborne due to an explosion | int teamNum |
| PLAYER_AIRBORNE_KNOCKBACK | A player is currently airborne due to knockback | int teamNum |
| PLAYER_NETPROP | A property of a player | [int teamNum, string propertyType, string propertyName, propertyValue]
| DAMAGE_TYPE | The type of damage caused | int ETFDmgCustom |
| ROUND_STATE | The state of the current round | int ERoundState |
| SERVER_MAP | The current map the server is playing | string mapName |
| SERVER_HOLIDAY | The current server holiday | int EHoliday |
