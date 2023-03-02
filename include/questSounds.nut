//TF_Quest
//	Team Fortress 2 questing system that recreates the Contracker
//


//questSounds.nut

//Settings
 //Sounds (Quest sounds)
local enableQuestSounds = GetSetting("enableQuestSounds")

//Vars
local soundScripts =
{
	//Quest Status
	questEnable = ""
	//Points Awarded
	questTickNovice = "Quest.StatusTickNovice"
	questTickNoviceFriend = "Quest.StatusTickNoviceFriend"
	questTickAdvanced = "Quest.StatusTickAdvanced"
	questTickAdvancedFriend = "Quest.StatusTickAdvancedFriend"
	questTickExpert = "Quest.StatusTickExpert"
	questTickExpertFriend = "Quest.StatusExpertFriend"
	//Objective Status
	questTickNoviceComplete = "Quest.StatusTickNoviceComplete"
	questTickAdvancedComplete = "Quest.StatusTickAdvancedComplete"
	questTickExpertComplete = "Quest.StatusTickExpertComplete"
}

//Functions

//void PlayQuestSound(handle Player, string soundScript)
//
//	This function will play an in-game sound for the Player.
//	if the Player has disabled playing Quest sounds, they
//	will not hear the sound.
//
function PlayQuestSound(hPlayer, soundScript)
{
	local player = FindPlayer(hPlayer)

	if (!enableQuestSounds)
		return null

	if (player != null && player.playerPreferences.enableQuestSounds)
	{
		if (enableQuestSounds && player.playerPreferences.enableQuestSounds)
		{
			//Precache sound
			hPlayer.PrecacheSoundScript(soundScripts[soundScript])

			//Play sound
			EmitSoundOnClient(soundScripts[soundScript], hPlayer)
			dPrint(6, "Playing (" + soundScript + ") for Player (" + hPlayer + ")")
		}
	}
}
