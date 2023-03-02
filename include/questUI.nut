//TODO
// Ensure function isn't creating lots of game_text entities

//TF_Quest
//	Team Fortress 2 questing system that recreates the Contracker
//


//quest.nut

//Settings
local enableQuestUI = GetSetting("enableQuestUI")

 //Quest Display
local questInfoDrawChannel =	//Medium used to display Quest progress
{
	chatbox = true,
	hud = true
}
local questInfoHud = 		//HUD Settings
{
	yPos = "-1"
	xPos = "1"
	color = "255, 255, 255" //White
	fadein = "0"
	fadeout = "0"
	holdtime = "9999"
}

local questObjectiveHud =
{
	yPos = "-1"
	xPos = "0"
	color = "255, 255, 255" //White
	fadein = "0"
	fadeout = "1"
	holdtime = "7"
}

//Functions

//void DisplayQuestProgress(handle Player)
//
//	This function will display the current
//	progress for the Player's first Quest
//	to their screen as a HUD element.
//
//	Note: this function requires one entity
//	to be created.
//
function DisplayQuestProgress(hPlayer)
{
	local player = FindPlayer(hPlayer)

	if (!enableQuestUI)
		return null

	if (player != null && !IsPlayerABot(hPlayer))
	{
		//Draw progress to HUD
		if (player.playerPreferences.enableQuestHUD)
		{
			local playerNID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")
			local playerQuestBook = GetPlayerBookEquipped(hPlayer)

			if (playerQuestBook != null)
			{
				local playerQuests = playerQuestBook.bookQuests
				local playerObjectives = playerQuestBook.bookObjectives
				local UIEntity = Entities.FindByName(null, "QI_" + playerNID)

				local message = FormatProgressMessage(hPlayer)

				//Create new UIEntity if not found
				if (UIEntity == null)
				{
					UIEntity = CreateUIEntity(hPlayer, "QI_" + playerNID, {
						message = "",
						x = questInfoHud.xPos,
						y = questInfoHud.yPos,
						effect = "0",
						color = questInfoHud.color,
						fadein = questInfoHud.fadein,
						fadeout = questInfoHud.fadeout,
						holdtime = questInfoHud.holdtime,
						channel = "1"
					})
				}

				//Display Quest Progress
				hPrint(hPlayer, UIEntity, message)
			}
		}
	}
}

//void DisplayQuestObjectives(handle Player)
//
//	This function will display the Player's
//	active Objectives for all Quests they
//	currently have.  It can display either
//	to the HUD, the chatbox, or both.
//
//	Note: this function requires one entity
//	to be created.
//
function DisplayQuestObjectives(hPlayer)
{
	local player = FindPlayer(hPlayer)
	local playerNID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")
	local charsPerSecond = 10
	local message = FormatObjectiveMessage(hPlayer)

	if (!enableQuestUI)
		return null

	if (player != null && !IsPlayerABot(hPlayer))
	{
		local playerQuestBook = GetPlayerBookEquipped(hPlayer)

		if (playerQuestBook != null)
		{
			local playerObjectives = GetObjectivesActive(hPlayer)

			if (playerObjectives.len() > 0)
			{
				if (player.playerPreferences.enableQuestChat)
					cPrint(hPlayer, message, true)

				if (player.playerPreferences.enableQuestHUD)
				{
					local UIEntity = Entities.FindByName(null, "QO_" + playerNID)

					if (UIEntity == null)
					{
						UIEntity = CreateUIEntity(hPlayer, "QO_" + playerNID, {
							message = "",
							x = questObjectiveHud.xPos,
							y = questObjectiveHud.yPos,
							effect = "0",
							color = questObjectiveHud.color,
							fadein = questObjectiveHud.fadein,
							fadeout = questObjectiveHud.fadeout,
							holdtime = message.len() / charsPerSecond, //Allow the Player enough time to read
							channel = "4"
						})
					}

					//Display Objectives
					hPrint(hPlayer, UIEntity, message)
				}
			}
		}
	}
}

//void DisplayQuestInfo(handle Player)
//
//	This function will both display Quest progress
//	and Quest Objectives to the Player.
//
function DisplayQuestInfo(hPlayer)
{
	//Display both Quest Progress and Quest Objectives
	DisplayQuestProgress(hPlayer)
	DisplayQuestObjectives(hPlayer)
}

//string FormatProgressMessage(handle Player)
//
//	This function will create a formatted string that
//	can be used to display the Player's first Quest to
//	their HUD or chatbox.
//
function FormatProgressMessage(hPlayer)
{
	local player = FindPlayer(hPlayer)
	local message = ""
	local subObjectiveCounter = 0

	if (player != null)
	{
		local playerQuestBook = GetPlayerBookEquipped(hPlayer)

		if (playerQuestBook != null)
		{
			local playerQuests = playerQuestBook.bookQuests
			local playerObjectives = playerQuestBook.bookObjectives

			foreach(objectiveArray in playerObjectives)
			{
				local quest = GetQuestByID(playerQuests[0])
				local objective = GetObjectiveByID(objectiveArray[0])
				local isObjectiveForQuest = (objective.objectiveParent.questID == quest.questID)

				if (objective != null && isObjectiveForQuest)
				{
					local playerCurrentPoints = objectiveArray[1]
					local playerMaxPoints = objective.objectiveTarget

					//Display only max points if Player's points overflow
					if (playerCurrentPoints > playerMaxPoints)
						playerCurrentPoints = playerMaxPoints

					//Begin Display message
					if (message == "")
					{
						message = quest.questName + "\n" + playerCurrentPoints + "/" + playerMaxPoints + " QP\n"
					}
					else
					{
						//Display 3 Sub-Objectives per row
						if (subObjectiveCounter < 3)
							message += "[" + playerCurrentPoints + "/" + playerMaxPoints + "]"
						else
						{
							message += "\n[" + playerCurrentPoints + "/" + playerMaxPoints + "]"
							subObjectiveCounter = 0
						}
						subObjectiveCounter++
					}
				}
			}

			//Player has additional Quests
			if (playerQuests.len() > 1)
				message += "\n(+" + (playerQuests.len() - 1) + " More Quests)"
		}

		return message
	}
}

//string FormatProgressMessage(handle Player)
//
//	This function will create a formatted string that
//	can be used to display the Player's objectives to
//	their HUD or chatbox.
//
function FormatObjectiveMessage(hPlayer)
{
	local player = FindPlayer(hPlayer)
	local message = "Your Objectives:"

	if (player != null)
	{
		local playerQuestBook = GetPlayerBookEquipped(hPlayer)

		if (playerQuestBook != null)
		{
			local playerQuests = playerQuestBook.bookQuests
			local playerObjectives = GetObjectivesActive(hPlayer)

			//Format active objective into message
			foreach(key, objective in playerObjectives)
			{
				//Format String
				message += "\n• " + objective.objectiveDesc + " (" + objective.objectiveAward + " QP)"

				if (playerQuests.len() > 1)
					message += " [" + objective.objectiveParent.questName + "]"
			}
		}

		return message
	}
}

//handle Entity CreateUIEntity(handle Player, string name, table table)
//
//	This function will create a new game_text entity
//	that can be used to display information to the
//	Player on the HUD.
//
function CreateUIEntity(hPlayer, name, table)
{
	local player = FindPlayer(hPlayer)

	if (player != null)
	{
		local playerNID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")

		local gametext = SpawnEntityFromTable("game_text", table)

		gametext.__KeyValueFromString("targetname", name)

		return gametext
		dPrint(5, "Created UIEntity (" + gametext + ") for Player (" + hPlayer + ")")
	}
}

//void RemoveUIForPlayer(handle Player, string name)
//
//	This function will delete a game_text entity
//	that has been created to display information
//	to the Player using their HUD.
//
function RemoveUIForPlayer(hPlayer, name)
{
	local playerNID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")
	local UIEntity = Entities.FindByName(null, name)

	if (UIEntity != null)
		UIEntity.Destroy()
	else
		dPrint(3, "Cannot destroy UIEntity for Player (" + hPlayer + ").  Not found.")
}