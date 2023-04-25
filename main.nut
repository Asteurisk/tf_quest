//TF_Quest
//	Team Fortress 2 questing system that recreates the Contracker
//


//main.nut

//Vars
local TF_BUILDABLES =
[
	//Engineer Buildables
	"obj_sentrygun"
	"obj_dispenser"
	"obj_teleporter"
	"tf_projectile_sentryrocket" //Sentries spawn Sentry Rockets
	//Spy Buildables
	"obj_attachment_sapper"
]

//Includes
IncludeScript("/tf_quest/settings.nut")
IncludeScript("/tf_quest/include/debug.nut")
IncludeScript("/tf_quest/include/objective.nut")
IncludeScript("/tf_quest/include/quest.nut")
IncludeScript("/tf_quest/include/tracker.nut")
IncludeScript("/tf_quest/include/chatCommands.nut")

//Functions
// ===========================================================
// Server/Game/Round Events
// ===========================================================

// ***********************************************************
// Sec. 1 of 2
// Events related to Player
//	Includes:
//	- Player Connected
//	- Player Disconnected
//	- Player Sent Chat
//	- Player Spawned
//	- Player Score Changed
// ***********************************************************

// -----------------------------------------------------------
//	Event: Player connected to Server
//
// -----------------------------------------------------------
function OnGameEvent_player_connect(params)
{
	// ...
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player disconnected
//
// -----------------------------------------------------------
function OnGameEvent_player_disconnect(params)
{
	//Handles
	local hPlayer

	//Tracker Players
	local player

	//Populate variables
	if ("userid" in params)
	{
		hPlayer = GetPlayerFromUserID(params.userid)
		player = FindPlayer(hPlayer)
	}

	if (player != null)
	{
		local playerNID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")
		local playerQuestBook = GetPlayerBook(hPlayer)

		//Force Player to leave their Party
		if (PlayerInParty(hPlayer))
		{
			local party = GetPartyWithPlayer(hPlayer)

			LeaveParty(party, hPlayer)
			dPrint(6, "Forced player to leave party")
		}

		//Remove Player's QuestBook
		if (playerQuestBook != null)
			RemoveQuestBook(playerQuestBook)

		//Delete any UI entities created for Player
		RemoveUIForPlayer(hPlayer, "QI_" + playerNID)
		RemoveUIForPlayer(hPlayer, "QO_" + playerNID)

		//Remove Player from Tracker
		ForgetPlayer(hPlayer)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player changed Info
//
// -----------------------------------------------------------
function OnGameEvent_player_changename(params)
{
	dPrint(6, "a Player has changed information")

	//Handles
	local hPlayer
	local oldName
	local newName

	//Tracker players
	local player

	if ("userid" in params)
	{
		hPlayer = GetPlayerFromUserID(params.userid)
		player = FindPlayer(hPlayer)
	}
	if ("oldname" in params)
		oldName = params.oldname
	if ("newname" in params)
		newName = params.newname

	if (player != null)
	{
		//Player has changed username, so we
		//need to update their tracked username

		if (newName != null)
			UpdateUserName(hPlayer, newName)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player sent chat message
//
// -----------------------------------------------------------
function OnGameEvent_player_say(params)
{
	//Handles
	local hPlayer
	local text

	//Tracker Players
	local player

	//Populate variables
	if ("userid" in params)
	{
		hPlayer = GetPlayerFromUserID(params.userid)
		player = FindPlayer(hPlayer)
	}
	if ("text" in params)
		text = params.text

	//Send message for processing
	if (hPlayer != null && text != null)
		ProcessChatCommand(hPlayer, text)

}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player spawned
//
// -----------------------------------------------------------
function OnGameEvent_player_spawn(params)
{
	dPrint(6, "a Player has spawned...")
	//Handles
	local hPlayer

	//Tracker Players
	local player

	//Populate variables
	if ("userid" in params)
	{
		hPlayer = GetPlayerFromUserID(params.userid)
		player = FindPlayer(hPlayer)
	}

	//Can't find Player in Tracker
	if (player == null)
	{
		local playerNID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")

		if (playerNID != "")
			TrackPlayer(hPlayer)
	}
	//Player found in Tracker
	else
	{
		DisplayQuestInfo(hPlayer)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player score changed
//
// -----------------------------------------------------------
function OnGameEvent_player_score_changed(params)
{
	//Handles
	local hPlayer
	local score

	//Tracker Players
	local player

	//Populate variables
	if ("player" in params)
	{
		hPlayer = PlayerInstanceFromIndex(params.player)
		player = FindPlayer(hPlayer)
	}
	if ("delta" in params)
	{
		score = params.delta
	}

	dPrint(6, hPlayer + " (hPlayer), " + score + " (score), " + player + " (player)")

	//Check Player's Quests
	if (player != null)
	{
		local objectiveTypes = ["GET_POINTS"]
		local objectiveParams =
		{
			PLAYER_SELF = hPlayer
		}

		//Set points
		local deltaScore
		if (score != null)
			deltaScore = score
		else
			deltaScore = 1

		dPrint(6, "Going to check!!!")
		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hPlayer, objectiveTypes, objectiveParams, deltaScore)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)
/* This event is not functioning properly
// -----------------------------------------------------------
//	Event: Player became MVP
//
// -----------------------------------------------------------
function OnGameEvent_player_mvp(params)
{
	dPrint(6, "A Player became MVP...")

	//Handles
	local hMVP

	//Tracker Players
	local playerMVP

	//Populate variables
	if ("player" in params)
	{
		hMVP = GetPlayerFromUserID(params.player)
		playerMVP = FindPlayer(hMVP)
	}

	//Check MVP's quests
	if (playerMVP != null)
	{
		local objectiveTypes = ["WIN_GAME_MVP"]
		local objectiveParams =
		{
			PLAYER_SELF = hMVP
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hMVP, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)
*/
// ***********************************************************
// Sec. 2 of 2
// Events related to Game
//	Includes:
//	- Round Started
//	- Round Ended
// ***********************************************************

// -----------------------------------------------------------
//	Event: Round begin
//
// -----------------------------------------------------------
function OnGameEvent_teamplay_round_start(params)
{
	//...
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Round ends
//
// -----------------------------------------------------------
function OnGameEvent_teamplay_round_win(params)
{
	dPrint(6, "A team has won the game...")

	//Handles
	local team

	//Tracker Players
	local players = FindPlayers()

	//Populate variables
	if ("team" in params)
	{
		team = params.team
	}

	//Check Players' Quests
	foreach(player in players)
	{
		local hPlayer = player.playerHandle

		local playerWinner = player
		local winner = team
		local loser

		if (winner == 3)
			loser = 2
		else
			loser = 3

		//Advance for winners
		if (hPlayer.GetTeam() == winner)
		{
			local objectiveTypes = ["WIN_GAME"]
			local objectiveParams =
			{
				PLAYER_SELF = hPlayer
			}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hPlayer, objectiveTypes, objectiveParams, 1)
		}

		//Save quests for Players
		SaveQuests(hPlayer)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// ===========================================================
// Player Events
// ===========================================================

// ***********************************************************
// Sec. 1 of 7
// Events related to general negative outcomes
//	Includes:
//	- Player Damaged
//	- Player Ignited
//	- Player Killed
//	- Player Killed (Environmental)
//	- Player Killed (Capturing)
//	- Player Dominated
//	- Player Stunned
//	- Player Destroyed Razorback
// ***********************************************************

// -----------------------------------------------------------
//	Event: Player took damage
//
// -----------------------------------------------------------
function OnGameEvent_player_hurt(params)
{
	dPrint(6, "A Player has been hurt...")

	//Handles
	local hAttacker
	local hVictim
	local damageType
	local damageTaken

	//Tracker Players
	local playerAttacker
	local playerVictim

	//Populate variables
	if ("attacker" in params)
	{
		hAttacker = GetPlayerFromUserID(params.attacker)
		playerAttacker = FindPlayer(hAttacker)
	}
	if ("userid" in params)
	{
		hVictim = GetPlayerFromUserID(params.userid)
		playerVictim = FindPlayer(hVictim)
	}
	if ("custom" in params)
		damageType = params.custom
	if ("damageamount" in params)
		damageTaken = params.damageamount

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["DAMAGE_PLAYER"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		//Populate objectiveParams
		if (hVictim != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hVictim
		if (damageType != null) //Damage Type
			objectiveParams.DAMAGE_TYPE <- damageType

		//Set points to give for damaging
		local damagePoints
		if (damageTaken != null)
			damagePoints = damageTaken
		else
			damagePoints = 1

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, damagePoints)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player was ignited
//
// -----------------------------------------------------------
function OnGameEvent_player_ignited(params)
{
	dPrint(6, "A Player has been ignited...")

	//Handles
	local hAttacker
	local hVictim

	//Tracker Players
	local playerAttacker
	local playerVictim

	//Populate variables
	if ("pyro_entindex" in params)
	{
		hAttacker = PlayerInstanceFromIndex(params.pyro_entindex)
		playerAttacker = FindPlayer(hAttacker)
	}
	if ("victim_entindex" in params)
	{
		hVictim = PlayerInstanceFromIndex(params.victim_entindex)
		playerVictim = FindPlayer(hVictim)
	}

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["IGNITE_PLAYER"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		//Populate objectiveParams
		if (hVictim != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hVictim

		//Reset objectiveType if Player ignited themself
		if (hVictim != null && hAttacker == hVictim)
			objectiveTypes = ["IGNITE_SELF"]

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player died
//
// -----------------------------------------------------------
function OnGameEvent_player_death(params)
{
	dPrint(6, "A Player has died...")

	//Handles
	local hAttacker
	local hAssister
	local hVictim
	local damageType
	local hInflictor
	local weaponName

	//Tracker Players
	local playerAttacker
	local playerAssister
	local playerVictim

	//Populate variables
	if ("attacker" in params)
	{
		hAttacker = GetPlayerFromUserID(params.attacker)
		playerAttacker = FindPlayer(hAttacker)
	}
	if ("assister" in params)
	{
		hAssister = GetPlayerFromUserID(params.assister)
		playerAssister = FindPlayer(hAssister)
	}
	if ("userid" in params)
	{
		hVictim = GetPlayerFromUserID(params.userid)
		playerVictim = FindPlayer(hVictim)
	}
	if ("customkill" in params)
		damageType = params.customkill
	if ("inflictor_entindex" in params)
		hInflictor = EntIndexToHScript(params.inflictor_entindex)
	if ("weapon" in params)
		weaponName = params.weapon

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["KILL_PLAYER"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}
		dPrint(6, "HasItem? " + hVictim.HasItem())
		//Populate objectiveParams
		if (hVictim != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hVictim
		if (hAssister != null) //Assister
			objectiveParams.PLAYER_FRIENDLY <- hAssister
		if (damageType != null) //Damage Type
			objectiveParams.DAMAGE_TYPE <- damageType
		if (hInflictor != null) //Buildables
		{
			if (TF_BUILDABLES.find(hInflictor.GetClassname()) != null)
				objectiveParams.ENTITY_BUILDABLE <- hInflictor
		}
		if (weaponName != null) //Weapon
			objectiveParams.ENTITY_WEAPON <- weaponName

		//Reset objectiveType if Player killed themself
		if (hVictim != null && hAttacker == hVictim)
			objectiveTypes = ["KILL_SELF"]

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}

	//Check Assister's Quests
	if (playerAssister != null)
	{
		local objectiveTypes = ["KILL_PLAYER_ASSIST"]
		local objectiveParams =
		{
			PLAYER_SELF = hAssister
		}

		//Populate objectiveParams
		if (hAttacker != null) //Attacker
			objectiveParams.PLAYER_FRIENDLY <- hAttacker
		if (hVictim != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hVictim
		if (hInflictor != null)	//Buildables
		{
			if (TF_BUILDABLES.find(hInflictor.GetClassname()) != null)
				objectiveParams.ENTITY_BUILDABLE <- hInflictor
		}

		//Reset objectiveType if Player killed themself
		if (hVictim != null && hAttacker == hVictim)
			objectiveTypes = ["KILL_SELF"]

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAssister, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player died to environment
//
// -----------------------------------------------------------
function OnGameEvent_environmental_death(params)
{
	dPrint(6, "A Player has died to environment...")

	//Handles
	local hAttacker
	local hVictim

	//Tracker Players
	local playerAttacker
	local playerVictim

	//Populate variables
	if ("killer" in params)
	{
		hAttacker = PlayerInstanceFromIndex(params.killer)
		playerAttacker = FindPlayer(hAttacker)
	}
	if ("victim" in params)
	{
		hVictim = PlayerInstanceFromIndex(params.victim)
		playerVictim = FindPlayer(hVictim)
	}

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["KILL_ENVIRONMENTAL"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		if (hVictim != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hVictim

		//Reset objectiveType if Player killed themself
		if (hVictim != null && hAttacker == hVictim)
			objectiveTypes = ["KILL_SELF"]

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player died while capping
//
// -----------------------------------------------------------
function OnGameEvent_killed_capping_player(params)
{
	dPrint(6, "A Player has died while capping...")

	//Handles
	local hAttacker
	local hVictim
	local hAssister

	//Tracker Players
	local playerAttacker
	local playerVictim
	local playerAssister

	//Populate variables
	if ("killer" in params)
	{
		hAttacker = PlayerInstanceFromIndex(params.killer)
		playerAttacker = FindPlayer(hAttacker)
	}
	if ("victim" in params)
	{
		hVictim = PlayerInstanceFromIndex(params.victim)
		playerVictim = FindPlayer(hVictim)
	}
	if ("assister" in params)
	{
		hAssister = PlayerInstanceFromIndex(params.assister)
		playerAssister = FindPlayer(hAssister)
	}

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["KILL_CAPPER"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		//Populate objectiveParams
		if (hVictim != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hVictim
		if (hAssister != null) //Assister
			objectiveParams.PLAYER_FRIENDLY <- hAssister

		//Reset objectiveType if Player killed themself
		if (hVictim != null && hAttacker == hVictim)
			objectiveTypes = ["KILL_SELF"]

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player was dominated
//
// -----------------------------------------------------------
function OnGameEvent_player_domination(params)
{
	dPrint(6, "A Player has been dominated...")

	//Handles
	local hAttacker
	local hVictim

	//Tracker Players
	local playerAttacker
	local playerVictim

	//Populate variables
	if ("dominator" in params)
	{
		hAttacker = GetPlayerFromUserID(params.dominator)
		playerAttacker = FindPlayer(hAttacker)
	}
	if ("dominated" in params)
	{
		hVictim = GetPlayerFromUserID(params.dominated)
		playerVictim = FindPlayer(hVictim)
	}

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["DOMINATE_PLAYER"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		//Populate objectiveParams
		if (hVictim != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hVictim

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player was stunned
//
// -----------------------------------------------------------
function OnGameEvent_player_stunned(params)
{
	dPrint(6, "A Player has been stunned...")

	//Handles
	local hAttacker
	local hVictim

	//Tracker Players
	local playerAttacker
	local playerVictim

	//Populate variables
	if ("stunner" in params)
	{
		hAttacker = GetPlayerFromUserID(params.stunner)
		playerAttacker = FindPlayer(hAttacker)
	}
	if ("victim" in params)
	{
		hVictim = GetPlayerFromUserID(params.victim)
		playerVictim = FindPlayer(hVictim)
	}

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["STUN_PLAYER"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		//Populate objectiveParams
		if (hVictim != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hVictim

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player broke Razorback
//
// -----------------------------------------------------------
function OnGameEvent_player_shield_blocked(params)
{
	dPrint(6, "A Player has broken a Razorback...")

	//Handles
	local hAttacker
	local hVictim

	//Tracker Players
	local playerAttacker
	local playerVictim

	//Populate variables
	if ("attacker_entindex" in params)
	{
		hAttacker = PlayerInstanceFromIndex(params.attacker_entindex)
		playerAttacker = FindPlayer(hAttacker)
	}
	if ("blocker_entindex" in params)
	{
		hVictim = PlayerInstanceFromIndex(params.blocker_entindex)
		playerVictim = FindPlayer(hVictim)
	}

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["DESTROY_RAZORBACK"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		if (hVictim != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hVictim

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}

	//Check Victim's Quests
	if (playerVictim != null)
	{
		local objectiveTypes = ["SURVIVE_KILL"]
		local objectiveParams =
		{
			PLAYER_SELF = hVictim
		}

		//Populate objectiveParams
		if (hVictim != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hAttacker

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// ***********************************************************
// Sec. 2 of 7
// Events related to general positive outcomes
//	Includes:
//	- Player Healed
//	- Player Uber'd
//	- Player Prevented Damage (Medigun Shield)
//	- Player Extinguished
//	- Player Shared Canteen
//	- Player Revived
// ***********************************************************

// -----------------------------------------------------------
//	Event: Player was healed
//
// -----------------------------------------------------------
function OnGameEvent_player_healed(params)
{
	dPrint(6, "A Player has been healed...")

	//Handles
	local hHealer
	local hPatient
	local healthGained

	//Tracker Players
	local playerHealer
	local playerPatient

	//Populate variables
	if ("healer" in params)
	{
		hHealer = GetPlayerFromUserID(params.healer)
		playerHealer = FindPlayer(hHealer)
	}
	if ("patient" in params)
	{
		hPatient = GetPlayerFromUserID(params.patient)
		playerPatient = FindPlayer(hPatient)
	}
	if ("amount" in params)
		healthGained = params.amount

	//Check Healer's Quests
	if (playerHealer != null)
	{
		local objectiveTypes = ["HEAL_PLAYER"]
		local objectiveParams =
		{
			PLAYER_SELF = hHealer
		}

		//Populate objectiveParams
		if (hPatient != null)
			objectiveParams.PLAYER_FRIENDLY <- hPatient

		//Set points to give for healing
		local healPoints
		if (healthGained != null)
			healPoints = healthGained
		else
			healPoints = 1

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hHealer, objectiveTypes, objectiveParams, healPoints)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player was uber'd
//
// -----------------------------------------------------------
function OnGameEvent_player_chargedeployed(params)
{
	dPrint(6, "A Player has been ubered...")

	//Handles
	local hHealer
	local hPatient

	//Tracker Players
	local playerHealer
	local playerPatient

	//Populate variables
	if ("userid" in params)
	{
		hHealer = GetPlayerFromUserID(params.userid)
		playerHealer = FindPlayer(hHealer)
	}
	if ("targetid" in params)
	{
		hPatient = GetPlayerFromUserID(params.targetid)
		playerPatient = FindPlayer(hPatient)
	}

	//Check Healer's Quests
	if (playerHealer != null)
	{
		local objectiveTypes = ["INVUL_PLAYER"]
		local objectiveParams =
		{
			PLAYER_SELF = hHealer
		}

		//Populate objectiveParams
		if (hPatient != null)
			objectiveParams.PLAYER_FRIENDLY <- hPatient

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hHealer, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)
/* This event is not functioning properly
// -----------------------------------------------------------
//	Event: Player prevented damage
//
// -----------------------------------------------------------
function OnGameEvent_damage_prevented(params)
{
	dPrint(6, "A Player has prevented damage...")

	//Handles
	local hHealer
	local hPatient
	local damagePrevented

	//Tracker Players
	local playerHealer
	local playerPatient

	//Populate variables
	if ("preventor" in params)
	{
		hHealer = GetPlayerFromUserID(params.preventor)
		playerHealer = FindPlayer(hHealer)
	}
	if ("victim" in params)
	{
		hPatient = GetPlayerFromUserID(params.victim)
		playerPatient = FindPlayer(hPatient)
	}
	if ("amount" in params)
		damagePrevented = params.amount

	//Check Preventer's Quests
	if (playerHealer != null)
	{
		local objectiveTypes = ["PREVENT_DAMAGE"]
		local objectiveParams =
		{
			PLAYER_SELF = hHealer
		}

		//Populate objectiveParams
		if (hPatient != null) //Patient
			objectiveParams.PLAYER_FRIENDLY <- hPatient

		//Set points to give for healing
		local damagePoints
		if (damagePrevented != null)
			damagePoints = damagePrevented
		else
			damagePoints = 1

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hHealer, objectiveTypes, objectiveParams, damagePoints)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)
*/
// -----------------------------------------------------------
//	Event: Player prevented damage with Medigun Shield
//
// -----------------------------------------------------------
function OnGameEvent_medigun_shield_blocked_damage(params)
{
	dPrint(6, "A Player has prevented damage with Medigun shield...")

	//Handles
	local hHealer
	local damagePrevented

	//Tracker Players
	local playerHealer

	//Populate variables
	if ("userid" in params)
	{
		hHealer = GetPlayerFromUserID(params.userid)
		playerHealer = FindPlayer(hHealer)
	}
	if ("damage" in params)
		damagePrevented = params.damage

	//Check Healer's Quests
	if (playerHealer != null)
	{
		local objectiveTypes = ["PREVENT_DAMAGE_MEDISHIELD"]
		local objectiveParams =
		{
			PLAYER_SELF = hHealer
		}

		//Set points to give for healing
		local damagePoints
		if (damagePrevented != null)
			damagePoints = damagePrevented
		else
			damagePoints = 1

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hHealer, objectiveTypes, objectiveParams, damagePoints)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player was extinguished
//
// -----------------------------------------------------------
function OnGameEvent_player_extinguished(params)
{
	dPrint(6, "A Player has been extinguished...")

	//Handles
	local hHealer
	local hPatient

	//Tracker Players
	local playerHealer
	local playerPatient

	//Populate variables
	if ("healer" in params)
	{
		hHealer = PlayerInstanceFromIndex(params.healer)
		playerHealer = FindPlayer(hHealer)
	}
	if ("victim" in params)
	{
		hPatient = PlayerInstanceFromIndex(params.victim)
		playerPatient = FindPlayer(playerPatient)
	}

	//Check Healer's Quests
	if (playerHealer != null)
	{
		local objectiveTypes = ["EXTINGUISH_PLAYER"]
		local objectiveParams =
		{
			PLAYER_SELF = hHealer
		}

		//Populate Objective parameters
		if (hPatient != null)
			objectiveParams.PLAYER_FRIENDLY <- hPatient

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hHealer, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)
/* This event is not functioning properly.
// -----------------------------------------------------------
//	Event: Player stole sandvich
//
// -----------------------------------------------------------
function OnGameEvent_player_stealsandvich(params)
{
	dPrint(6, "A Player has stolen a sandvich...")

	//Handles
	local hStealer
	local hOwner

	//Tracker Players
	local playerStealer
	local playerOwner

	//Populate variables
	if ("owner" in params)
	{
		hOwner = GetPlayerFromUserID(params.owner)
		playerOwner = FindPlayer(hOwner)
	}
	if ("target" in params)
	{
		hStealer = GetPlayerFromUserID(params.target)
		playerStealer = FindPlayer(hStealer)
	}

	//Check Stealer's Quests
	if (playerStealer != null)
	{
		local objectiveTypes = ["STEAL_SANDVICH"]
		local objectiveParams =
		{
			PLAYER_SELF = hStealer
		}

		//Populate objectiveParams
		if (hStealer != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hOwner

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hStealer, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)
*/
// -----------------------------------------------------------
//	Event: Player shared Canteen
//
// -----------------------------------------------------------
function OnGameEvent_mvm_medic_powerup_shared(params)
{
	dPrint(6, "A Player has shared their canteen...")

	//Handles
	local hHealer

	//Tracker Players
	local playerHealer

	//Populate variables
	if ("player" in params)
	{
		hHealer = PlayerInstanceFromIndex(params.player)
		playerHealer = FindPlayer(hHealer)
	}

	//Check Healer's Quests
	if (playerHealer != null)
	{
		local objectiveTypes = ["SHARE_CANTEEN"]
		local objectiveParams =
		{
			PLAYER_SELF = hHealer
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hHealer, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player revived dead Player
//
// -----------------------------------------------------------
function OnGameEvent_revive_player_complete(params)
{
	dPrint(6, "A Player has been revived...")

	//Handles
	local hHealer

	//Tracker Players
	local playerHealer

	//Populate variables
	if ("player" in params)
	{
		hHealer = PlayerInstanceFromIndex(params.player)
		playerHealer = FindPlayer(hHealer)
	}

	//Check Healer's Quests
	if (playerHealer != null)
	{
		local objectiveTypes = ["REVIVE_PLAYER"]
		local objectiveParams =
		{
			PLAYER_SELF = hHealer
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hHealer, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// ***********************************************************
// Sec. 3 of 7
// Events related to buildables
//	Includes:
//	- Player Built Object
//	- Player Upgraded Object
//	- Player Healed Object
//	- Player Destroyed Object
//	- Player Sapped Object
//	- Player Teleported
// ***********************************************************

// -----------------------------------------------------------
//	Event: Player built Buildable
//
// -----------------------------------------------------------
function OnGameEvent_player_builtobject(params)
{
	dPrint(6, "A Player has built a buildable...")

	//Handles
	local hBuilder
	local hBuilding

	//Tracker Players
	local playerBuilder

	//Populate variables
	if ("userid" in params)
	{
		hBuilder = GetPlayerFromUserID(params.userid)
		playerBuilder = FindPlayer(hBuilder)
	}
	if ("index" in params)
		hBuilding = EntIndexToHScript(params.index)

	//Check Builder's Quests
	if (playerBuilder != null)
	{
		local objectiveTypes = ["BUILD_BUILDABLE"]
		local objectiveParams =
		{
			PLAYER_SELF = hBuilder
		}

		//Populate objectiveParams
		if (hBuilding != null) //Buildables
		{
			if (TF_BUILDABLES.find(hBuilding.GetClassname()) != null)
				objectiveParams.ENTITY_BUILDABLE <- hBuilding
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hBuilder, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player upgraded Buildable
//
// -----------------------------------------------------------
function OnGameEvent_player_upgradedobject(params)
{
	dPrint(6, "A Player has upgraded a buildable...")

	//Handles
	local hBuilder
	local hBuilding
	local isBuilder

	//Tracker Players
	local playerBuilder

	//Populate variables
	if ("userid" in params)
	{
		hBuilder = GetPlayerFromUserID(params.userid)
		playerBuilder = FindPlayer(hBuilder)
	}
	if ("index" in params)
		hBuilding = EntIndexToHScript(params.index)
	if ("isbuilder" in params)
		isBuilder = params.isbuilder

	//Check Builder's Quests (If Player who upgraded owns this building)
	if (playerBuilder != null)
	{
		local objectiveTypes = ["UPGRADE_BUILDABLE"]
		local objectiveParams = {}

		//Populate objectiveParams
		if (isBuilder != null && isBuilder)
			objectiveParams.PLAYER_SELF <- hBuilder

		//Populate objectiveParams
		if (hBuilding != null) //Buildables
		{
			if (TF_BUILDABLES.find(hBuilding.GetClassname()) != null)
				objectiveParams.ENTITY_BUILDABLE <- hBuilding
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hBuilder, objectiveTypes, objectiveParams, 1)
	}
	//Check Upgrader's Quest (If Player who upgraded isn't building's Owner)
	if (isBuilder != null && !isBuilder)
	{
		local objectiveTypes = ["UPGRADE_BUILDABLE_ASSIST"]
		local objectiveParams =
		{
			PLAYER_SELF = hBuilder
			PLAYER_FRIENDLY = NetProps.GetPropEntity(hBuilding, "m_hBuilder")
		}

		//Populate objectiveParams
		if (hBuilding != null) //Buildables
		{
			if (TF_BUILDABLES.find(hBuilding.GetClassname()) != null)
				objectiveParams.ENTITY_BUILDABLE <- hBuilding
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hBuilder, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player healed buildable
//
// -----------------------------------------------------------
function OnGameEvent_building_healed(params)
{
	dPrint(6, "A Player has healed a building...")

	//Handles
	local hBuilder
	local hBuilding
	local healthGained

	//Tracker Players
	local playerBuilder

	//Populate variables
	if ("healer" in params)
	{
		hBuilder = GetPlayerFromUserID(params.healer)
		playerBuilder = FindPlayer(hBuilder)
	}
	if ("building" in params)
		hBuilding = EntIndexToHScript(params.building)
	if ("amount" in params)
		healthGained = params.amount

	//Check Builder's Quests
	if (playerBuilder != null)
	{
		local objectiveTypes = ["HEAL_BUILDABLE"]
		local objectiveParams =
		{
			PLAYER_SELF = hBuilder
		}

		//Populate objectiveParams
		if (hBuilding != null) //Buildables
		{
			if (TF_BUILDABLES.find(hBuilding.GetClassname()) != null)
				objectiveParams.ENTITY_BUILDABLE <- hBuilding
		}

		//Set points to give for healing
		local healPoints
		if (healthGained != null)
			healPoints = healthGained
		else
			healPoints = 1

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hBuilder, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player destroyed buildable
//
// -----------------------------------------------------------
function OnGameEvent_object_destroyed(params)
{
	dPrint(6, "A Player has destroyed a building...")

	//Handles
	local hAttacker
	local hAssister
	local hVictim
	local hBuilding
	local weaponName

	//Tracker Players
	local playerAttacker
	local playerAssister
	local playerVictim

	//Populate variables
	if ("attacker" in params)
	{
		hAttacker = GetPlayerFromUserID(params.attacker)
		playerAttacker = FindPlayer(hAttacker)
	}
	if ("assister" in params)
	{
		hAssister = GetPlayerFromUserID(params.assister)
		playerAssister = FindPlayer(hAssister)
	}
	if ("userid" in params)
	{
		hVictim = GetPlayerFromUserID(params.userid)
		playerVictim = FindPlayer(hVictim)
	}
	if ("index" in params)
		hBuilding = EntIndexToHScript(params.index)
	if ("weapon" in params)
		weaponName = params.weapon

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["DESTROY_BUILDABLE"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		//Populate objectiveParams
		if (hVictim != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hVictim
		if (hAssister != null) //Assister
		{
			objectiveParams.PLAYER_ASSISTER <- hAssister
			objectiveTypes.append("DESTROY_BUILDABLE_ASSIST")
		}
		if (hBuilding != null) //Buildables
		{
			if (TF_BUILDABLES.find(hBuilding.GetClassname()) != null)
				objectiveParams.ENTITY_BUILDABLE <- hBuilding
		}
		if (weaponName != null) //Weapon
			objectiveParams.ENTITY_WEAPON <- weaponName

		//Reset objectiveType if Player destroyed their own building
		if (hVictim != null && hAttacker == hVictim)
			objectiveTypes = ["DESTROY_BUILDING_SELF"]

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player sapped buildable
//
// -----------------------------------------------------------
function OnGameEvent_player_sapped_object(params)
{
	dPrint(6, "A Player has sapped a buildable...")

	//Handles
	local hAttacker
	local hBuilding
	local hVictim

	//Tracker Players
	local playerAttacker
	local playerVictim

	//Populate variables
	if ("userid" in params)
	{
		hAttacker = GetPlayerFromUserID(params.userid)
		playerAttacker = FindPlayer(hAttacker)
	}
	if ("ownerid" in params)
	{
		hVictim = GetPlayerFromUserID(params.ownerid)
		playerVictim = FindPlayer(hVictim)
	}
	if ("object" in params)
		hBuilding = EntIndexToHScript(params.object)


	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["SAPPED_BUILDABLE"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		//Populate objectiveParams
		if (hVictim != null) //Victim
			objectiveParams.PLAYER_ENEMY <- hVictim
		if (hBuilding != null) //Buildables
		{
			if (TF_BUILDABLES.find(hBuilding.GetClassname()) != null)
				objectiveParams.ENTITY_BUILDABLE <- hBuilding
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player was teleported
//
// -----------------------------------------------------------
function OnGameEvent_player_teleported(params)
{
	dPrint(6, "A Player has been teleported...")

	//Handles
	local hBuilder
	local hPassenger

	//Tracker Players
	local playerBuilder
	local playerPassenger

	//Populate variables
	if ("builderid" in params)
	{
		hBuilder = GetPlayerFromUserID(params.builderid)
		playerBuilder = FindPlayer(hBuilder)
	}
	if ("userid" in params)
	{
		hPassenger = GetPlayerFromUserID(params.userid)
		playerPassenger = FindPlayer(hPassenger)
	}

	//Check Builder's Quests
	if (playerBuilder != null)
	{
		local objectiveTypes = ["TELEPORT_PLAYER"]
		local objectiveParams =
		{
			PLAYER_SELF = hBuilder
		}

		//Populate objectiveParams
		if (hPassenger != null && hPassenger.GetTeam() == hBuilder.GetTeam()) //Friendly Passenger
			objectiveParams.PLAYER_FRIENDLY <- hPassenger
		else if (hPassenger != null && hPassenger.GetTeam() != hBuilder.GetTeam()) //Enemy Passenger
			objectiveParams.PLAYER_ENEMY <- hPassenger

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hBuilder, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// ***********************************************************
// Sec. 4 of 7
// Events related to pickups
//	Includes:
//	- Player Grabbed Crumpkin
//	- Player Grabbed Gift
//	- Player Grabbed Money
// ***********************************************************

// -----------------------------------------------------------
//	Event: Player grabbed crit pumpkin
//
// -----------------------------------------------------------
function OnGameEvent_halloween_pumpkin_grab(params)
{
	dPrint(6, "A Player has grabbed a crumpkin...")

	//Handles
	local hPlayer

	//Tracker Players
	local player

	//Populate variables
	if ("userid" in params)
	{
		hPlayer = GetPlayerFromUserID(params.userid)
		player = FindPlayer(hPlayer)
	}

	//Check Grabber's Quests
	if (player != null)
	{
		local objectiveTypes = ["PICKUP_CRUMPKIN"]
		local objectiveParams =
		{
			PLAYER_SELF = hPlayer
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hPlayer, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player grabbed Christmas gift
//
// -----------------------------------------------------------
function OnGameEvent_christmas_gift_grab(params)
{
	dPrint(6, "A Player has grabbed a Christmas gift...")

	//Handles
	local hPlayer

	//Tracker Players
	local player

	//Populate variables
	if ("userid" in params)
	{
		hPlayer = GetPlayerFromUserID(params.userid)
		player = FindPlayer(hPlayer)
	}

	//Check Grabber's Quests
	if (player != null)
	{
		local objectiveTypes = ["PICKUP_GIFT"]
		local objectiveParams =
		{
			PLAYER_SELF = hPlayer
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hPlayer, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Player grabbed MvM Money
//
// -----------------------------------------------------------
function OnGameEvent_mvm_pickup_currency(params)
{
	dPrint(6, "A Player has grabbed money...")

	//Handles
	local hPlayer
	local currencyAmount

	//Tracker Players
	local player

	//Populate variables
	if ("player" in params)
	{
		hPlayer = PlayerInstanceFromIndex(params.player)
		player = FindPlayer(hPlayer)
	}
	if ("currency" in params)
		currencyAmount = params.currency

	//Check Grabber's Quests
	if (player != null)
	{
		local objectiveTypes = ["PICKUP_MONEY"]
		local objectiveParams =
		{
			PLAYER_SELF = hPlayer
		}

		//Set points to give for healing
		local currencyPoints
		if (currencyAmount != null)
			currencyPoints = currencyAmount
		else
			currencyPoints = 1

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hPlayer, objectiveTypes, objectiveParams, currencyPoints)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// ***********************************************************
// Sec. 5 of 7
// Events related to gamemode objectives
//	Includes:
//	- Player(s) Captured Point
//	- Player Defended Point
//	- Player Grabbed/Captured/Defended Flag
// ***********************************************************

// -----------------------------------------------------------
//	Event: Point captured
//
// -----------------------------------------------------------
function OnGameEvent_teamplay_point_captured(params)
{
	dPrint(6, "A point has been captured...")

	//Handles
	local hCappers

	if ("cappers" in params)
		hCappers = params.cappers

	//Check Cappers' Quests
	foreach(index in hCappers)
	{
		local hCapper = PlayerInstanceFromIndex(index)
		local playerCapper = FindPlayer(hCapper)

		if (playerCapper != null)
		{
			local objectiveTypes = ["CAPTURE_POINT", "CAPTURE_OBJECTIVE"]
			local objectiveParams =
			{
				PLAYER_SELF = hCapper
			}

			//Check if Objective should advance for Player
			CheckObjectiveForPlayer(hCapper, objectiveTypes, objectiveParams, 1)
		}
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Point defended
//
// -----------------------------------------------------------
function OnGameEvent_teamplay_capture_blocked(params)
{
	// Capture blocked after victim dies
	dPrint(6, "A point has been defended...")

	//Handles
	local hAttacker
	local hVictim

	//Tracker Players
	local playerAttacker
	local playerVictim

	//Populate variables
	if ("blocker" in params)
	{
		hAttacker = PlayerInstanceFromIndex(params.blocker)
		playerAttacker = FindPlayer(hAttacker)
	}
	if ("victim" in params)
	{
		hVictim = PlayerInstanceFromIndex(params.victim)
		playerVictim = FindPlayer(hVictim)
	}

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["DEFEND_POINT", "DEFEND_OBJECTIVE"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		//Populate objectiveParams
		if (hVictim != null)
			objectiveParams.PLAYER_ENEMY <- hVictim

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// -----------------------------------------------------------
//	Event: Flag Event occured
//
// -----------------------------------------------------------
function OnGameEvent_teamplay_flag_event(params)
{
	dPrint(6, "A flag event has occured...")

	//Handles
	local hPlayer
	local hCarrier
	local eventType

	//Tracker Players
	local player
	local playerCarrier

	//Populate variables
	if ("player" in params)
	{
		hPlayer = PlayerInstanceFromIndex(params.player)
		player = FindPlayer(hPlayer)
	}
	if ("carrier" in params)
	{
		hCarrier = PlayerInstanceFromIndex(params.carrier)
		playerCarrier = FindPlayer(hCarrier)
	}
	if ("eventtype" in params)
		eventType = params.eventtype

	//Check Player's Quests
	if (player != null)
	{
		local objectiveTypes = []
		local objectiveParams =
		{
			PLAYER_SELF = hPlayer
		}

		//Populate objectiveParams
		if (hCarrier != null) //Carrier
			objectiveParams.PLAYER_ENEMY <- hCarrier

		//Populate objectiveTypes
		if (eventType != null)
		{
			switch (eventType)
			{
				case 1 :
					objectiveTypes.append("PICKUP_FLAG")
				break
				case 2 :
					objectiveTypes.append("CAPTURE_FLAG")
					objectiveTypes.append("CAPTURE_OBJECTIVE")
				break
				case 3 :
					objectiveTypes.append("DEFEND_FLAG")
					objectiveTypes.append("DEFEND_OBJECTIVE")
				break
			}
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hPlayer, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// ***********************************************************
// Sec. 6 of 7
// Events related to Mann vs Machine
//	Includes:
//	- Player(s) Completed Wave
//	- Player Reset Bomb Deployment
//	- Player(s) Destroy Tank
// ***********************************************************

// -----------------------------------------------------------
//	Event: Players won MvM wave
//
// -----------------------------------------------------------
function OnGameEvent_mvm_wave_complete(params)
{
	dPrint(6, "A team has completed a wave...")

	//Tracker Players
	local players = FindPlayers()

	//Check Players' Quests
	foreach(player in players)
	{
		local hPlayer = player.playerHandle

		if (player != null)
		{
			local objectiveTypes = ["WIN_WAVE"]
			local objectiveParams =
			{
				PLAYER_SELF = hPlayer
			}

			//Check if Objective should advance for Player
			CheckObjectiveForPlayer(hPlayer, objectiveTypes, objectiveParams, 1)

			//Save Player's Quests
			SaveQuests(hPlayer)
		}
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)
/* This event is not working properly.
// -----------------------------------------------------------
//	Event: Player killed robot that was delivering the bomb
//
// -----------------------------------------------------------
function OnGameEvent_mvm_kill_robot_delivering_bomb(params)
{
	dPrint(6, "A Robot has died while delivering the bomb...")

	//Handles
	local hAttacker

	//Tracker Players
	local playerAttacker

	//Populate variables
	if ("player" in params)
	{
		hAttacker = PlayerInstanceFromIndex(params.player)
		playerAttacker = FindPlayer(hAttacker)
	}

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["KILL_ROBOT_DELIVERING_BOMB"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)
*/
// -----------------------------------------------------------
//	Event: Player prevented bomb deployment
//
// -----------------------------------------------------------
function OnGameEvent_mvm_bomb_deploy_reset_by_player(params)
{
	dPrint(6, "A Player has prevented the bomb from being deployed...")

	//Handles
	local hPlayer

	//Tracker Players
	local player

	//Populate variables
	if ("userid" in params)
	{
		hPlayer = GetPlayerFromUserID(params.userid) // GetPlayerFromUserID Might be the wrong one check this
		player = FindPlayer(hPlayer)
	}

	//Check Attacker's Quests
	if (player != null)
	{
		local objectiveTypes = ["RESET_BOMB_DEPLOY"]
		local objectiveParams =
		{
			PLAYER_SELF = hPlayer
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hPlayer, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)
/*
// -----------------------------------------------------------
//	Event: Player reset bomb
//
// -----------------------------------------------------------
function OnGameEvent_mvm_bomb_reset_by_player(params)
{
	dPrint(6, "A Player has reset the bomb...")

	//Handles
	local hPlayer

	//Tracker Players
	local player

	//Populate variables
	if ("userid" in params)
	{
		hPlayer = GetPlayerFromUserID(params.userid)
		player = FindPlayer(hPlayer)
	}

	//Check Attacker's Quests
	if (player != null)
	{
		local objectiveTypes = ["RESET_BOMB"]
		local objectiveParams =
		{
			PLAYER_SELF = hPlayer
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hPlayer, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)
*/
/* This event is not functioning properly.
// -----------------------------------------------------------
//	Event: Player detonated Sentry Buster
//
// -----------------------------------------------------------
function OnGameEvent_mvm_sentrybuster_detonate(params)
{
	dPrint(6, "A Sentry Buster has detonated...")

	//Handles
	local hAttacker

	//Tracker Players
	local playerAttacker

	//Populate variables
	if ("player" in params)
	{
		hAttacker = PlayerInstanceFromIndex(params.player)
		playerAttacker = FindPlayer(hAttacker)
	}

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["KILL_SENTRYBUSTER"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, 1)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)
*/
// -----------------------------------------------------------
//	Event: Players destroyed tank
//
// -----------------------------------------------------------
function OnGameEvent_mvm_tank_destroyed_by_players(params)
{
	dPrint(6, "A team has destroyed the tank...")

	//Tracker Players
	local players = FindPlayers()

	//Check Players' Quests
	foreach(player in players)
	{
		local hPlayer = player.playerHandle

		if (player != null)
		{
			local objectiveTypes = ["DESTROY_TANK"]
			local objectiveParams =
			{
				PLAYER_SELF = hPlayer
			}

			//Check if Objective should advance for Player
			CheckObjectiveForPlayer(hPlayer, objectiveTypes, objectiveParams, 1)
		}
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// ***********************************************************
// Sec. 7 of 7
// Events related to Non-Player Characters
//	Includes:
//	- NPC Hurt
// ***********************************************************

// -----------------------------------------------------------
//	Event: Boss took damage
//
// -----------------------------------------------------------
function OnGameEvent_npc_hurt(params)
{
	dPrint(6, "A Boss has been hurt...")

	//Handles
	local hAttacker
	local hVictim
	local hWeapon
	local damageTaken

	//Tracker Players
	local playerAttacker

	//Populate variables
	if ("attacker_player" in params)
	{
		hAttacker = GetPlayerFromUserID(params.attacker_player)
		playerAttacker = FindPlayer(hAttacker)
	}
	if ("entindex" in params)
	{
		hVictim = EntIndexToHScript(params.entindex)
	}
	if ("damageamount" in params)
		damageTaken = params.damageamount

	//Check Attacker's Quests
	if (playerAttacker != null)
	{
		local objectiveTypes = ["DAMAGE_BOSS"]
		local objectiveParams =
		{
			PLAYER_SELF = hAttacker
		}

		//Populate objectiveParams
		if (hVictim != null)
			objectiveParams.PLAYER_ENEMY <- hVictim

		//Set points to give for damaging
		local damagePoints
		if (damageTaken != null)
			damagePoints = damageTaken
		else
			damagePoints = 1

		//Check if Objective should advance for Player
		CheckObjectiveForPlayer(hAttacker, objectiveTypes, objectiveParams, damagePoints)
	}
}

__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

//End of Script
dPrint(4, "TF_Quest VScript Enabled!")
TrackAllPlayers()