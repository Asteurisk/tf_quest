//TODO
// See if can rewrite AdvancePlayerQuest for better readability

//TF_Quest
//	Team Fortress 2 questing system that recreates the Contracker
//


//quest.nut

//Settings
 //Quests (All files in "quests" must be included here)
local maxQuestsPerPlayer = GetSetting("maxQuestsPerPlayer")

//Includes
IncludeScript("tf_quest/include/questSounds.nut")
IncludeScript("/tf_quest/include/questUI.nut")
IncludeScript("/tf_quest/include/questFriends.nut")
IncludeScript("/tf_quest/include/questSave.nut")

//Vars
local questList = []
local objectiveList = []
local bookList = []

//Functions

//table CreateQuest(table quest)
//
//	This function is used to create a table that
//	stores information about a single Quest.
//	All information about a Quest is stored within
//	this table.
//
//	Note that questObjectives does not store tables created
//	from CreateObjective, only the raw data from the
//	QuestScript itself.
//
function CreateQuest(quest)
{
	if (quest != null)
	{
		local questTable = {
			questID = questList.len()
			questName = quest.quest_name
			questDesc = quest.quest_desc
			questMode = quest.quest_mode
			questMission = quest.quest_mission
			questObjectives = quest.quest_mission.mission_objectives
		}

		return questTable
	}
}

//table CreateObjective(table quest, table objective)
//
//	This function is used to create a table that
//	stores information about a single Objective
//	from a Quest.  All information about an Objective
//	is stored within this table.
//
function CreateObjective(quest = null, objective = null)
{
	if (quest != null && objective != null)
	{
		local objectiveTable = {
			objectiveParent = quest
			objectiveID = objectiveList.len()
			objectiveName = objective.objective_name
			objectiveDesc = objective.objective_desc
			objectivePoints = objective.objective_points
			objectiveAward = objective.objective_award
			objectiveTarget = objective.objective_target
			objectiveType = objective.objective_type
			objectiveFlags = objective.objective_flags
		}

		return objectiveTable
	}
}

//table CreateQuestBook(handle Player)
//
//	This function is used to create a table that stores
//	a Player's active Quests and Objectives.  A QuestBook
//	can be owned by many Players, but only one Player can
//	be the "owner".
//
function CreateQuestBook(hPlayer)
{
	local bookTable = {
		bookID = bookList.len()
		bookOwner = hPlayer
		bookQuests = []
		bookObjectives = []
	}

	return bookTable
}

//table AddQuest(table quest)
//
//	This function is used to create a new Quest instance from
//	a table of values, that usually being from a questScript
//
function AddQuest(quest)
{
	local questNames = []
	local objectiveNames = []

	foreach(Quest in questList)
		questNames.append(Quest.questName)

	//Check if Quest w/ name already exists
	if (questNames.find(quest.quest_name) != null)
	{
		dPrint(1, "Duplicate Quest entry detected! Quest (" + quest.quest_name + ").  Skipping Quest")
		return null
	}

	//Check if Objective w/ name already exists in this Quest
	foreach(objective in quest.quest_mission.mission_objectives)
	{
		//Duplicate objective in quest found
		if (objectiveNames.find(objective.objective_name) != null)
		{
			dPrint(1, "Duplicate Objective entry detected! Quest (" + quest.quest_name + ") for Objective (" + objective.objective_name + ").  Skipping Quest")
			return null
		}
		//No duplicate found
		else
			objectiveNames.append(objective.objective_name)
	}

	//Create new Quest from class Quest
	local newQuest = CreateQuest(quest)

	//Append to Quest list
	questList.append(newQuest)

	//Create new Objectives from class Objective
	foreach(objective in quest.quest_mission.mission_objectives)
		objectiveList.append(CreateObjective(newQuest, objective))

	dPrint(4, "New Quest (" + newQuest.questID + ") [" + newQuest.questName + "] created with (" + newQuest.questObjectives.len() + ") Objectives")
	return quest
}

//void AddQuestFromFile(string fileName)
//
//	This function is used to hot-load Quest Scripts from their file
//	as long as the Quest Script calls the AddQuest() function
//
function AddQuestFromFile(fileName)
{
	//Add Quest
	try
	{
		//Add .nut extension if needed
		if (fileName.find(".nut") == null)
			fileName += ".nut"

		IncludeScript("/tf_quest/quests/" + fileName)
	}
	catch (exception)
	{
		dPrint(2, "Cannot include Quest Script (" + fileName + ")!")
	}
}

//void AddQuestFromFile(array fileNames)
//
//	This function is used to hot-load Quest Scripts from their file
//	as long as the Quest Script calls the AddQuest() function
//
function AddQuestFromFiles(fileNames)
{
	//Add Quests
	foreach(fileName in fileNames)
		AddQuestFromFile(fileName)
}

//void GiveQuest(handle Player, table Quest)
//
//	This function is used to assign a Quest to a Player
//	by adding the Quest instance to the Player's "quests"
//	array, created from tracker.nut
//
function GiveQuest(hPlayer, quest)
{
	local player = FindPlayer(hPlayer)

	if (player != null)
	{
		local playerQuestBook = GetPlayerBookEquipped(hPlayer)

		if (playerQuestBook != null)
		{
			local playerQuests = playerQuestBook.bookQuests
			local playerObjectives = playerQuestBook.bookObjectives

			//Cancel if Player has reached Max Quests
			if (playerQuests.len() >= maxQuestsPerPlayer)
			{
				cPrint(hPlayer, "You must complete or remove a Quest before adding another!")
				return null
			}

			//Cancel if Player has already started this Quest
			if (playerQuests.find(quest.questID) != null)
			{
				cPrint(hPlayer, "You cannot equip the same Quest twice!")
				return null
			}

			//Give Player Quest's ID
			playerQuestBook.bookQuests.append(quest.questID)

			//Give Player Objectives' IDs
			foreach(objective in objectiveList)
			{
				//Ensure Objective is for this Quest
				if (objective.objectiveParent.questID == quest.questID)
				playerQuestBook.bookObjectives.append([objective.objectiveID, objective.objectivePoints])
			}

			//Player Quest Message
			cPrint(hPlayer, "Started Quest (" + quest.questName + ")")
			dPrint(4, "Player (" + player.playerName + ") has started Quest (" + quest.questName + ")")

			//Display Quest Info for all Players with QuestBook
			foreach(hPlayer in GetPlayersWithBook(playerQuestBook))
			{
				DisplayQuestInfo(hPlayer)
			}
		}
	}
}


//void GiveQuestByName(handle Player, string questName)
//
//	This function will give a Quest to a Player
//	by looking for the Quest by name from the
//	questList array.
//
function GiveQuestByName(hPlayer, questName)
{
	//Find Quest with Name from questName
	local quests = GetQuests()

	foreach(quest in quests)
	{
		local questName = quest.questName

		if (questName == questName)
		{
			//Add Quest to Player
			local player = FindPlayer(hPlayer)

			if (player != null)
			{
				GiveQuest(hPlayer, quest)
				return null
			}
		}
	}
}

//void RemoveQuest(handle Player, table Quest)
//
//	This function will remove a Quest, matching the identifier,
//	from the Player's "quests" array, created from tracker.nut.
//	After removing the Quest, it will remove any Objectives that
//	were given when starting the Quest.
//
function RemoveQuest(hPlayer, quest)
{
	local player = FindPlayer(hPlayer)

	if (player != null)
	{
		local playerQuestBook = GetPlayerBookEquipped(hPlayer)

		if (playerQuestBook != null)
		{
			local playerQuests = playerQuestBook.bookQuests
			local playerObjectives = playerQuestBook.bookObjectives

			local questIndex = playerQuests.find(quest.questID)

			//Find and Remove Quest
			if (questIndex != null)
			{
				playerQuestBook.bookQuests.remove(questIndex)

				//Find and Remove Objectives
				local objectivesToRemove = []

				//Find Objectives
				foreach(key, objectiveArray in playerObjectives)
				{
					local objectiveID = objectiveArray[0]
					local objective = GetObjectiveByID(objectiveID)

					if (objective != null)
					{
						local isObjectiveMatching = objective.objectiveID == objectiveID
						local isQuestMatching = objective.objectiveParent.questID == quest.questID

						if (isObjectiveMatching && isQuestMatching)
							objectivesToRemove.append(key)
					}
				}

				//Remove Objectives, starting from Highest to Lowest
				for(local i=objectivesToRemove.len()-1;i>=0;i-=1)
				{
					playerQuestBook.bookObjectives.remove(objectivesToRemove[i])
				}

				//Remove Quest Info from HUD
				foreach(hPlayer in GetPlayersWithBook(playerQuestBook))
				{
					DisplayQuestInfo(hPlayer)
				}
			}
		}
	}
}

//table GiveQuestBook(handle Player)
//
//	This function will either give the Player
//	a new QuestBook (they don't have one), or
//	it will return the Player's personal QuestBook
//	(they already have one)
//
function GiveQuestBook(hPlayer)
{
	//Create new QuestBook for Player
	if (!GetPlayerBook(hPlayer))
	{
		local questBook = CreateQuestBook(hPlayer)
		bookList.append(questBook)

		dPrint(5, "Created new QuestBook (" + questBook.bookID + ")")

		return questBook
	}
	//Player has QuestBook available
	else
		return GetPlayerBook(hPlayer)
}

//void RemoveQuestBook(table questBook)
//
//	This function will delete a QuestBook
//	from storage and remove it from any Player
//	that currently is using it.
//

function RemoveQuestBook(questBook)
{
	local bookIndex = bookList.find(questBook)

	if (bookIndex != null)
	{
		foreach (hPlayer in GetPlayersWithBook(questBook))
		{
			local player = FindPlayer(hPlayer)

			if (player != null)
				player.playerQuestBook = null
		}

		bookList.remove(bookIndex)
		dPrint(5, "Removed QuestBook (" + questBook.bookID + ")")
	}
}

//table GetQuestBook(table questBook)
//
//	This function will return a questBook
//
function GetQuestBook(questBook)
{
	foreach(questBook in bookList)
	{
		if (questBook.bookID == questBook.bookID)
			return questBook
	}
}

//table GetPlayerBook(handle Player)
//
//	This function will return the personal
//	QuestBook owned by the Player.  Note that
//	the Player can only have one personal QuestBook.
//
function GetPlayerBook(hPlayer)
{
	foreach(questBook in bookList)
	{
		if (questBook.bookOwner == hPlayer)
			return questBook
	}
}

//table GetPlayerBookEquipped(handle Player)
//
//	This function will return a QuestBook
//	that the player is currently using,
//	whether it is from a Party or their
//	own personal QuestBook.
//
function GetPlayerBookEquipped(hPlayer)
{
	local player = FindPlayer(hPlayer)
	return player.playerQuestBook
}

//array GetPlayersWithBook(table questBook)
//
//	This function will return each player that
//	currently has a QuestBook equipped, whether
//	the book is their personal QuestBook or
//	a QuestBook given from a Party.
//
function GetPlayersWithBook(questBook)
{
	local players = FindPlayers()
	local bookPlayers = []

	foreach(player in players)
	{
		local playerQuestBook = GetPlayerBookEquipped(player.playerHandle)

		if (playerQuestBook != null)
		{
			if (playerQuestBook.bookID == questBook.bookID)
				bookPlayers.append(player.playerHandle)
		}
	}

	return bookPlayers
}

//array GetQuests()
//
//	This function will return all available
//	Quests from the questList array.
//
function GetQuests()
{
	//Return Quest list
	return questList
}

//bool PlayerHasQuest(handle Player, table quest)
//
//	This function will return whether or not
//	the Player currently has a Quest in their
//	equipped QuestBook.
//
function PlayerHasQuest(hPlayer, quest)
{
	local player = FindPlayer(hPlayer)

	if (player != null)
	{
		local playerQuestBook = GetPlayerBookEquipped(hPlayer)

		if (playerQuestBook != null)
		{
			if (playerQuestBook.bookQuests.find(quest.questID) != null)
				return true
			else
				return false
		}
	}
}

//table GetQuestByID(int questID)
//
//	This function will return the
//	Quest that matches the questID value.
//
function GetQuestByID(questID)
{
	foreach(quest in questList)
	{
		if (quest.questID == questID)
			return quest
	}

}

//table GetFirstQuestByName(string questName)
//
//	This function will return the
//	first Quest that matches the questName
//	value.
//
function GetFirstQuestByName(questName)
{
	foreach(quest in questList)
	{
		if (quest.questName == questName)
			return quest
	}
}

//table GetObjectivesForQuestByID(int questID)
//
//	This function will return all Objectives that
//	are within a Quest that matches the questID value
//
function GetObjectivesForQuestByID(questID)
{
	local quest = GetQuestByID(questID)
	local objectives = []

	foreach(objective in objectiveList)
	{
		if (objective.objectiveParent.questID == quest.questID)
			objectives.append(objective)
	}

	return objectives
}

//table GetObjectiveByID(int objectiveID)
//
//	This function will return a single Objective
//	that matches the objectiveID value
//
function GetObjectiveByID(objectiveID)
{
	foreach(objective in objectiveList)
	{
		if (objective.objectiveID == objectiveID)
			return objective
	}
}

//table GetFirstObjectiveByName(table quest, string objectiveName)
//
//	This function will return a single Objective
//	that is an Objective in the quest value and matches
//	the first instance of an Objective of the same name.
//
function GetFirstObjectiveByName(quest, objectiveName)
{
	foreach(objective in objectiveList)
	{
		if (objective.objectiveParent.questName == quest.questName && objective.objectiveName == objectiveName)
			return objective
	}
}

//table GetObjectivesActive(handle Player)
//
//	This function will return Objectives that
//	the Player has not yet finished for any Quests.
//
function GetObjectivesActive(hPlayer)
{
	//Get Objectives Player has not completed
	local objectives = []
	local player = FindPlayer(hPlayer)

	if (player != null)
	{
		local playerQuestBook = GetPlayerBookEquipped(hPlayer)

		if (playerQuestBook != null)
		{
			foreach(objectiveArray in playerQuestBook.bookObjectives)
			{
				local objectiveID = objectiveArray[0]
				local playerCurrentPoints = objectiveArray[1]
				local objective = GetObjectiveByID(objectiveID)
				local playerMaxPoints = objective.objectiveTarget

				if (playerCurrentPoints < playerMaxPoints)
				{
					//Player has not completed this objective
					objectives.append(objective)
				}
			}

			return objectives
		}
	}
}

//table GetObjectivesInactive(hPlayer)
//
//	This function will return Objectives that
//	the Player has already completed for any Quests.
//
function GetObjectivesInactive(hPlayer)
{
	//Get Objectives Player has completed
	local objectives = []
	local player = FindPlayer(hPlayer)

	if (player != null)
	{
		local playerQuestBook = GetPlayerBookEquipped(hPlayer)

		if (playerQuestBook != null)
		{
			foreach(objectiveArray in playerQuestBook.bookObjectives)
			{
				local objectiveID = objectiveArray[0]
				local playerCurrentPoints = objectiveArray[1]
				local objective = GetObjectiveByID(objectiveID)
				local playerMaxPoints = objective.objectiveTarget

				if (playerCurrentPoints >= playerMaxPoints)
				{
					//Player has completed this objective
					objectives.append(GetObjectiveByID(objective))
				}
			}
		}
	}
}

//int GetPlayerObjectiveIndex(handle Player, table objective)
//
//	This function will return the index value of
//	the objective information stored in the Player's
//	QuestBook.
//
//	Note that the Player's QuestBook stores two values per
//	Objective, an ID and the points gained for that Objective
//
function GetPlayerObjectiveIndex(hPlayer, objective)
{
	local player = FindPlayer(hPlayer)

	if (player != null)
	{
		local playerQuestBook = GetPlayerBookEquipped(hPlayer)

		if (playerQuestBook != null)
		{
			foreach(key, playerObjective in playerQuestBook.bookObjectives)
			{
				if (playerObjective[0] == objective.objectiveID)
					return key

			}
		}
	}
}

//table GetObjectivesActiveForQuest(handle Player, table quest)
//
//	This function will return any Objectives not yet
//	completed by the Player as long as they come from
//	the quest value.
//
function GetObjectivesActiveForQuest(hPlayer, quest)
{
	local objectives = []
	local player = FindPlayer(hPlayer)

	if (player != null)
	{
		local playerActiveObjectives = GetObjectivesActive(hPlayer)

		foreach(objective in playerActiveObjectives)
		{
			if (objective.objectiveParent == quest)
				objectives.append(objective)
		}
		return objectives
	}
}

//void CheckObjectiveForPlayer(handle Player, table objectiveTypes, table objectiveParams, int objectiveGivePoints)
//
//	This function determines if a Player has an Objective that matches the
//	event that occured and triggered this function.  If a matching objectiveType
//	is found, we check if the Player succesfully advanced their objective.  If so,
//	we advance their quest.
//
function CheckObjectiveForPlayer(hPlayer, objectiveTypes, objectiveParams, objectiveGivePoints)
{
	local player = FindPlayer(hPlayer)

	if (player != null)
	{
		local playerQuestBook = GetPlayerBookEquipped(hPlayer)

		if (playerQuestBook != null)
		{
			local playerQuests = playerQuestBook.bookQuests
			local playerObjectives = playerQuestBook.bookObjectives

			if (playerQuests.len() > 0)
			{
				//Iterate through Player's Objectives
				foreach(objectiveArray in playerObjectives)
				{
					local playerObjectiveID = objectiveArray[0]
					local objective = GetObjectiveByID(playerObjectiveID)
					local objectiveTypeFound = objectiveTypes.find(objective.objectiveType)

					if (objective != null && objectiveTypeFound != null)
					{
						local shouldProgress = ProgressObjective(hPlayer, objective, objectiveParams)
						local quest = objective.objectiveParent

						if (shouldProgress)
						{
							if (objective.objectiveAward >= 0)
								AdvanceQuestForPlayer(hPlayer, quest, objective) //Advance quest, let questScript determine points awarded
							else
								AdvanceQuestForPlayer(hPlayer, quest, objective, objectiveGivePoints) //Advance quest, let objectiveGivePoints determine points awarded
						}
					}
				}
			}
		}
	}
}

//void AdvanceQuestForPlayer(handle Player, table quest, table objective, int pointsOverwrite, bool friendBoosted)
//
//	This function simply gives the Player points for advancing their Objective.
//	If the player has a Friend, that Friend will also receive points.
//
function AdvanceQuestForPlayer(hPlayer, quest, objective, pointsOverwrite = null, friendBoosted = null)
{
	local player = FindPlayer(hPlayer)
	local playerName = NetProps.GetPropString(hPlayer, "m_szNetname")

	//Advance Quest only for tracked Players
	if (player != null)
	{
		local playerQuestBook = GetPlayerBookEquipped(hPlayer)

		if (playerQuestBook != null)
		{
			local playersWithBook = GetPlayersWithBook(playerQuestBook)
			local playerObjectives = playerQuestBook.bookObjectives

			//Iterate through Player's Objectives to find Objective that needs updating
			foreach(key, objectiveArray in playerObjectives)
			{
				local playerObjectiveID = objectiveArray[0]
				local playerCurrentPoints = objectiveArray[1]
				local playerObjective = GetObjectiveByID(playerObjectiveID)
				local objectiveParentID = playerObjective.objectiveParent.questID
				local playerMaxPoints = playerObjective.objectiveTarget

				//Ignore Objective if we completed it
				if (playerCurrentPoints >= playerMaxPoints)
					continue

				//Match Player's Objective
				if (playerObjectiveID == objective.objectiveID)
				{
					local questMode = playerObjective.objectiveParent.questMode
					local primaryObjective = GetObjectivesForQuestByID(quest.questID)[0]
					local primaryIndex = GetPlayerObjectiveIndex(hPlayer, primaryObjective)

					//Award points to Objective(s)

					//Contracker Mode
					// In this mode, all Objectives give points toward the primary (first)
					// Objective in the Quest.  The amount of points given to the primary
					// Objective is based on the objectiveAward amount (-1 means tf_quest decides)
					if (questMode == "contracker")
					{
						//Objectives must be in the same Quest
						if (primaryObjective.objectiveParent == playerObjective.objectiveParent)
						{
							local pointsToGive = playerObjective.objectiveAward + playerObjectives[primaryIndex][1]

							//Let TF_Quest determine points (objective_award = -1)
							if (pointsToGive == -1 && pointsOverwite != null)
								pointsToGive = pointsOverwrite

							//Assign points to primary Objective, then secondary Objective
							if (primaryObjective.objectiveID != playerObjective.objectiveID)
							{
								local secondaryPoints = playerCurrentPoints + 1

								//Primary
								SetObjectivePoints(playerQuestBook, primaryIndex, pointsToGive)

								//Secondary
								SetObjectivePoints(playerQuestBook, key, secondaryPoints)
							}
							//Assign points to primary Objective
							else
							{
								SetObjectivePoints(playerQuestBook, key, pointsToGive)
							}
						}
					}
					//Quest Mode
					// In this mode, Objectives only give points toward themselves.  The amount of points
					// given is based on the value specified in objectiveAward (-1 means tf_quest decides)
					else if (questMode == "quest")
					{
						local pointsToGive = playerObjective.objectiveAward + playerCurrentPoints

						//Let TF_Quest determine points (objective_award = -1)
						if (pointsToGive == -1 && pointsOverwite != null)
							pointsToGive = pointsOverwrite

						SetObjectivePoints(playerQuestBook, key, pointsToGive)
					}

					//Get updated points
					local playerNewPoints = playerObjectives[key][1]

					//Player just completed Objective
					if (playerNewPoints >= playerMaxPoints)
					{
						//Objective complete message
						local completeMsg = null

						//Format "completed" message
						if (primaryObjective == playerObjective)
							completeMsg = playerName + " completed the primary Objective (" + objective.objectiveName + ") for their Quest (" + quest.questName + ")"
						else
							completeMsg = playerName + " completed a difficult Objective (" + objective.objectiveName + ") for their Quest (" + quest.questName + ")"

						//Print "completed" message
						if (playersWithBook.len() <= 1)
							cPrint(null, completeMsg)
						else
							cPrint(null, completeMsg + " for their party")

						foreach(hBookPlayer in playersWithBook)
						{
							//Play "Objective complete" sound
							if (hBookPlayer == hPlayer)
								PlayQuestSound(hBookPlayer, "questTickAdvanced")
							else
								PlayQuestSound(hBookPlayer, "questTickAdvancedFriend")

							//Refresh Objectives Display
							DisplayQuestProgress(hBookPlayer)
						}
					}
					//Player is still completing Objective
					else
					{
						foreach(hBookPlayer in playersWithBook)
						{
							//Play "Get pont" sound
							if (hBookPlayer == hPlayer)
								PlayQuestSound(hBookPlayer, "questTickNovice")
							else
								PlayQuestSound(hBookPlayer, "questTickNoviceFriend")

							//Refresh Objectives Display
							DisplayQuestProgress(hBookPlayer)
						}
					}
				}
			}

			//Check Objectives remaining for Quest
			if (GetObjectivesActiveForQuest(hPlayer, quest).len() == 0)
			{
				//Remove Quest from Book
				RemoveQuest(hPlayer, quest)

				//Reset save progress
				ResetSaveForQuest(hPlayer, quest)

				//Play "Quest Completed" sound for Players w/ QuestBook
				foreach(hBookPlayer in playersWithBook)
				{
					PlayQuestSound(hBookPlayer, "questTickNoviceComplete")
				}

				cPrint(null, playerName + " completed Quest (" + quest.questName + ")")
			}
		}
	}
}

//void SetObjectivePoints(table questBook, int objectiveIndex, int points)
//
//	This function will modify the points value from the Player's
//	QuestBook to be the value points
//
function SetObjectivePoints(questBook, objectiveIndex, points)
{
	questBook.bookObjectives[objectiveIndex][1] = points
}