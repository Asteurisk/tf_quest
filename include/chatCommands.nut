//TF_Quest
//	Team Fortress 2 questing system that recreates the Contracker
//


//chatCommands.nut

//Settings
local allowCommands = GetSetting("allowCommands")
local commandBlacklist = GetSetting("commandBlacklist")
local cmdMark = GetSetting("commandDelimeter")

//Functions

//void ProcessChatCommand(handle Player, string message)
//
//	This function will search for patterns in the value message
//	and do further processing if the pattern matches a case
//	within this function.
//
function ProcessChatCommand(hPlayer, message)
{
	local chatResponse = ""
	local chatNoBranding = false

	if (message.find(cmdMark) != null)
	{
		local command = GetCommandFromString(message)
		local cmdParam = GetParamFromString(message)

		if (!allowCommands)
			return null


		if (commandBlacklist.find(command) != null)
		{
			cPrint(hPlayer, "This command has been disabled.")
			return null
		}

		//Commands
		if (message.find(cmdMark + "StartParty") != null)
		{
			//Start Party
			local player = FindPlayer(hPlayer)

			if (player != null)
			{
				AddParty(hPlayer)
			}
		}
		else if (message.find(cmdMark + "JoinParty") != null)
		{
			if (cmdParam != null)
			{
				//Find Player with Username from cmdParam
				local players = FindPlayers()

				foreach(player in players)
				{
					local hLeader = player.playerHandle

					if (player.playerName == cmdParam)
					{
						local party = GetPartyWithPlayer(hLeader)

						if (party != null)
						{
							SendJoinRequest(party, hPlayer)
							return
						}

					}
				}
			}
		}
		else if (message.find(cmdMark + "LeaveParty") != null)
		{
			//Remove Player from Party
			local player = FindPlayer(hPlayer)

			if (player != null)
			{
				local party = GetPartyWithPlayer(hPlayer)

				if (party != null)
					LeaveParty(party, hPlayer)
			}
		}
		else if (message.find(cmdMark + "Accept") != null)
		{
			//Accept Party Join Request
			if (cmdParam != null)
			{
				//Find Player with Username from cmdParam
				local players = FindPlayers()

				foreach(player in players)
				{
					local hMember = player.playerHandle

					if (player.playerName == cmdParam)
					{
						local party = GetPartyWithPlayer(hPlayer)

						if (party != null)
						{
							AcceptJoinRequest(party, hMember)
							return
						}
					}
				}
			}
		}
		else if (message.find(cmdMark + "StartQuest") != null)
		{
			//Start Quest
			if (cmdParam != null)
			{
				local player = FindPlayer(hPlayer)

				if (player != null)
				{
					local quest = GetFirstQuestByName(cmdParam)

					if (quest != null)
					{
						if (HasSaveForQuest(hPlayer, quest) && GetSetting("enableQuestSaves"))
							LoadQuest(hPlayer, quest)
						else
							GiveQuest(hPlayer, quest)
					}
					else
						chatResponse = "No matching quest found!"
				}
			}
		}
		else if (message.find(cmdMark + "ListQuests") != null)
		{
			//List available Quests
			local player = FindPlayer(hPlayer)

			if (player != null)
			{
				local playerQuestBook = GetPlayerBookEquipped(hPlayer)

				if (playerQuestBook != null)
				{
					//Get Quests
					local quests = GetQuests()

					if (quests.len() == 0)
						chatResponse = "No quests to display!"

					foreach(key, quest in quests)
					{
						local questName = quest.questName

						//Disable [TF_QUEST] branding
						chatNoBranding = true

						if (chatResponse == "")
							chatResponse = "Available Quests:\n[" + (key + 1) + "] " + questName
						else
							chatResponse += "\n[" + (key + 1) + "] " + questName

						//Mark that Player has quest
						if (playerQuestBook.bookQuests.find(quest.questID) != null)
							chatResponse += " [*]"
					}
				}
			}
		}
		else if (message.find(cmdMark + "RemoveQuest") != null)
		{
			//Remove Quest
			if (cmdParam != null)
			{
				local player = FindPlayer(hPlayer)

				if (player != null)
				{
					local quest = GetFirstQuestByName(cmdParam)

					if (quest != null)
					{
						local playerQuestBook = GetPlayerBookEquipped(hPlayer)

						if (playerQuestBook != null)
						{
							if (playerQuestBook.bookOwner == hPlayer)
								RemoveQuest(hPlayer, quest)
							else
								chatResponse = "Only the Leader can remove Quests!"

							return null
						}
					}
					else
						chatResponse = "No matching quest found!"
				}
			}
		}
		else if (message.find(cmdMark + "ShowObjectives") != null)
		{
			local player = FindPlayer(hPlayer)

			if (player != null)
			{
				DisplayQuestObjectives(hPlayer)
			}
		}
		else if (message.find(cmdMark + "ToggleSounds") != null)
		{
			local player = FindPlayer(hPlayer)

			if (!GetSetting("enableQuestSounds"))
			{
				cPrint(hPlayer, "Quest sounds have been globally disabled.")
				return null
			}

			if (player != null)
			{
				player.playerPreferences.enableQuestSounds = !player.playerPreferences.enableQuestSounds

				if (player.playerPreferences.enableQuestSounds)
					chatResponse = "Enabled Quest sounds"
				else
					chatResponse = "Disabled Quest sounds"
			}
		}
		else if (message.find(cmdMark + "ToggleHUD") != null)
		{
			local player = FindPlayer(hPlayer)

			if (!GetSetting("enableQuestUI"))
			{
				cPrint(hPlayer, "Quest UI has been globally disabled.")
				return null
			}

			if (player != null)
			{
				player.playerPreferences.enableQuestHUD = !player.playerPreferences.enableQuestHUD

				if (player.playerPreferences.enableQuestHUD)
					chatResponse = "Enabled Quest HUD"
				else
					chatResponse = "Disabled Quest HUD"

				DisplayQuestInfo(hPlayer)
			}
		}
		else if (message.find(cmdMark + "ToggleChat") != null)
		{
			local player = FindPlayer(hPlayer)

			if (!GetSetting("enableQuestUI"))
			{
				cPrint(hPlayer, "Quest UI has been globally disabled.")
				return null
			}

			if (player != null)
			{
				player.playerPreferences.enableQuestChat = !player.playerPreferences.enableQuestChat

				if (player.playerPreferences.enableQuestChat)
					chatResponse = "Enabled Quest Chatbox"
				else
					chatResponse = "Disabled Quest Chatbox"

				DisplayQuestInfo(hPlayer)
			}
		}

		if (chatResponse.len() != 0)
			cPrint(hPlayer, chatResponse, chatNoBranding)
	}
}

//string GetCommandFromString(string message)
//
//	This function will return the command without
//	any parameters.
//
function GetCommandFromString(message)
{
	//Search command message
	if (message.find(cmdMark) != null)
	{
		local str = message
		local strStart = message.find(cmdMark) //Find the beginning of the command
		local strEnd = message.find(" ", (strStart + 1)) // Find the end of the command
		//Isolate command
		if (strStart != null)
		{

			//Message has Param
			if (strEnd != null)
				str = str.slice(strStart, (strEnd + 1))

			return str
		}
	}
}

//string GetParamFromString
//
//	This function will return the parameter
//	that was sent with the command.
//
function GetParamFromString(message)
{
	//Search command message
	if (message.find(cmdMark) != null)
	{
		local str = message
		local strStart = message.find(cmdMark) //Find the beginning of the command
		local strEnd = message.find(" ", (strStart + 1)) //Find the end of the command

		//Isolate command parameter
		if (strStart != null && strEnd != null)
		{
			str = str.slice(strEnd + 1)
			return str
		}
	}
}