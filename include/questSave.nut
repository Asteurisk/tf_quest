//TF_Quest
//	Team Fortress 2 questing system that recreates the Contracker
//


//questSave.nut

//Settings

local saveDir = GetSetting("savePlayerQuestsDir")
local enableQuestSaves = GetSetting("enableQuestSaves")

//Save Format
//  ;QUESTNAME;!OBJECTIVENAME!#PLAYERPOINTS#...

//Functions

//void SaveQuests(handle Player)
//
//  This function will save a formatted string
//  to a file so that it the Player can later
//  load their quests if needed.
//
//  Note: Windows OS cannot create files with : character,
//  so it must be removed
//
function SaveQuests(hPlayer)
{
    local player = FindPlayer(hPlayer)

    if (!enableQuestSaves)
        return null

    if (player != null && !IsPlayerABot(hPlayer))
    {
        local playerQuestBook = GetPlayerBook(hPlayer)

        if (playerQuestBook != null)
        {
            local playerQuests = playerQuestBook.bookQuests

            if (playerQuests.len() > 0)
            {
                local saveCurrQuest = GetStringFromQuests(hPlayer)
                local playerNID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")
                local NIDFormatted = playerNID.slice(5, playerNID.len() - 1)

                //Save current quest progress
                StringToFile(saveDir + "QS_" + NIDFormatted, saveCurrQuest)

                //Save individual quest progress
                foreach(playerQuest in playerQuests)
                {
                    local quest = GetQuestByID(playerQuest)
                    local saveQuest = GetStringFromQuest(hPlayer, quest)

                    StringToFile(saveDir + "Q_" + NIDFormatted + "!" + quest.questName, saveQuest)
                }

                cPrint(hPlayer, "Personal quest progress saved.")
                dPrint(5, "Saved Quests for Player (" + hPlayer + ")")
            }
        }
    }
}

function LoadQuest(hPlayer, quest)
{
    local player = FindPlayer(hPlayer)
    local saveObjectives = []

    //Quest saving must be enabled
    if (!enableQuestSaves)
        return null

    if (player != null && !IsPlayerABot(hPlayer))
    {
        local playerQuestBook = GetPlayerBookEquipped(hPlayer)

        if (playerQuestBook != null)
        {
            local playerQuests = playerQuestBook.bookQuests
            local playerNID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")
            local NIDFormatted = playerNID.slice(5, playerNID.len() - 1)
            local saveString = FileToString(saveDir + "Q_" + NIDFormatted + "!" + quest.questName.tolower())

            //Player must have room for more Quests
            if (playerQuests.len() >= GetSetting("maxQuestsPerPlayer"))
            {
                cPrint(hPlayer, "Cannot load quest, you must complete or remove a quest.")
                return null
            }

            if (saveString != null)
            {
                //Player has completed this Quest before
                if (saveString == "RESET_PROGRESS")
                {
                    GiveQuest(hPlayer, quest)
                    return null
                }

                //Loop saveString to populate saveQuests and saveObjectives
                while(saveString.find("@") != null)
                {
                    //Get Quest Name
                    local strFilter = FilterSaveString(saveString, "@")

                    local strQuestName = strFilter[0]
                    saveString = strFilter[1]

                    if (strQuestName != null)
                    {
                        local quest = GetFirstQuestByName(strQuestName)

                        if (quest != null)
                        {
                            //Get Objective Name
                            local strFilter = FilterSaveString(saveString, "#")

                            local strObjectiveName = strFilter[0]
                            saveString = strFilter[1]

                            if (quest != null && strObjectiveName != null)
                            {
                                local objective = GetFirstObjectiveByName(quest, strObjectiveName)

                                //Get Player Points
                                local strFilter = FilterSaveString(saveString, "^")

                                local strPlayerPoints = strFilter[0]
                                saveString = strFilter[1]

                                if (objective != null && strPlayerPoints != null)
                                    saveObjectives.append([quest, objective, strPlayerPoints])
                            }
                        }
                        else
                            dPrint(3, "Player (" + player.playerName + ") had save, but no Quest of name (" + strQuestName + ") found!")
                    }
                }
            }

            if (saveObjectives.len() > 0)
            {

                //Loop saveObjectives to apply Quests to Player
                foreach(saveArray in saveObjectives)
                {
                    local playerQuestBook = GetPlayerBook(hPlayer)

                    if (playerQuestBook != null)
                    {
                        local playerObjectives = playerQuestBook.bookObjectives
                        local quest = saveArray[0]
                        local objective = saveArray[1]
                        local playerPoints = saveArray[2]

                        //Apply Quest to Player if needed
                        if (!PlayerHasQuest(hPlayer, quest))
                            GiveQuest(hPlayer, quest)

                        //Set points for Objective
                        foreach(key, objectiveArray in playerObjectives)
                        {
                            if (objectiveArray[0] == objective.objectiveID)
                            {
                                SetObjectivePoints(playerQuestBook, key, playerPoints.tointeger())
                            }
                        }
                    }
                }

                dPrint(5, "Loaded Quest (" + quest.questName + ") for Player (" + hPlayer + ")")
                cPrint(hPlayer, "Loaded quest progress.")
                DisplayQuestProgress(hPlayer)
            }
        }
    }
}

//void LoadQuests (handle Player)
//
//  This function will take a string from a file and
//  parse it to get information about the Quest, Objectives,
//  and current points for those Objectives.  The Player will
//  then be given the matching Objectives with points set.
//
function LoadQuests(hPlayer)
{
    local player = FindPlayer(hPlayer)
    local saveObjectives = []

    if (!enableQuestSaves)
        return null

    if (player != null && !IsPlayerABot(hPlayer))
    {
        local playerNID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")
        local NIDFormatted = playerNID.slice(5, playerNID.len() - 1)
        local saveString = FileToString(saveDir + "QS_" + NIDFormatted)

        if (saveString != null)
        {
            //Loop saveString to populate saveQuests and saveObjectives
            while(saveString.find("@") != null)
            {
                //Get Quest Name
                local strFilter = FilterSaveString(saveString, "@")

                local strQuestName = strFilter[0]
                saveString = strFilter[1]

                if (strQuestName != null)
                {
                    local quest = GetFirstQuestByName(strQuestName)

                    if (quest != null)
                    {
                        //Get Objective Name
                        local strFilter = FilterSaveString(saveString, "#")

                        local strObjectiveName = strFilter[0]
                        saveString = strFilter[1]

                        if (quest != null && strObjectiveName != null)
                        {
                            local objective = GetFirstObjectiveByName(quest, strObjectiveName)

                            //Get Player Points
                            local strFilter = FilterSaveString(saveString, "^")

                            local strPlayerPoints = strFilter[0]
                            saveString = strFilter[1]

                            if (objective != null && strPlayerPoints != null)
                                saveObjectives.append([quest, objective, strPlayerPoints])
                        }
                    }
                    else
                        dPrint(3, "Player (" + player.playerName + ") had save, but no Quest of name (" + strQuestName + ") found!")
                }
            }
        }

        if (saveObjectives.len() > 0)
        {

            //Loop saveObjectives to apply Quests to Player
            foreach(saveArray in saveObjectives)
            {
                local playerQuestBook = GetPlayerBook(hPlayer)

                if (playerQuestBook != null)
                {
                    local playerQuests = playerQuestBook.bookQuests
                    local playerObjectives = playerQuestBook.bookObjectives
                    local quest = saveArray[0]
                    local objective = saveArray[1]
                    local playerPoints = saveArray[2]

                    //Apply Quest to Player if needed
                    if (!PlayerHasQuest(hPlayer, quest))
                    {
                        //Only allow max number of Quests for Player
                        if (playerQuests.len() >= GetSetting("maxQuestsPerPlayer"))
                        {
                            cPrint(hPlayer, "Failed to load additional quests, max quest limit reached.")
                            return null
                        }
                        else
                            GiveQuest(hPlayer, quest)
                    }

                    //Set points for Objective
                    foreach(key, objectiveArray in playerObjectives)
                    {
                        if (objectiveArray[0] == objective.objectiveID)
                        {
                            SetObjectivePoints(playerQuestBook, key, playerPoints.tointeger())
                        }
                    }
                }
            }

            dPrint(5, "Loaded Quests for Player (" + hPlayer + ")")
            DisplayQuestProgress(hPlayer)
        }
    }
}

//void ResetSaveForQuest(handle Player, table quest)
//
//  This function will mark a Quest progress file
//  for reset for whenever the Player starts the
//  same Quest again later.
//
//  Note: Windows OS cannot create files with : character,
//  so it must be removed
//
function ResetSaveForQuest(hPlayer, quest)
{
    local playerNID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")
    local NIDFormatted = playerNID.slice(5, playerNID.len() - 1)

    StringToFile(saveDir + "Q_" + NIDFormatted + "!" + quest.questName, "RESET_PROGRESS")
}

//bool HasSaveForQuest(handle Player, table quest)
//
//  This function will return true if the Player
//  has a Quest progress file for the specified quest
//  or false if they do not.
//
function HasSaveForQuest(hPlayer, quest)
{
    local playerNID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")
    local NIDFormatted = playerNID.slice(5, playerNID.len() - 1)

    if (FileToString(saveDir + "Q_" + NIDFormatted + "!" + quest.questName.tolower()) != null)
        return true
    else
        return false
}

//string GetStringFromQuests(handle Player)
//
//  This function will create a formatted string
//  that represents the Player's current Quests,
//  Objectives, and points.
//
function GetStringFromQuests(hPlayer)
{
    local player = FindPlayer(hPlayer)

    if (player != null)
    {
        local playerQuestBook = GetPlayerBook(hPlayer)

        if (playerQuestBook != null)
        {
            local playerQuests = playerQuestBook.bookQuests
            local playerObjectives = playerQuestBook.bookObjectives

            if (playerQuests.len() > 0)
            {
                local saveString = ""

                //Create save section for each Objective
                foreach(objectiveArray in playerObjectives)
                {
                    local objectiveID = objectiveArray[0]
                    local playerPoints = objectiveArray[1]
                    local objective = GetObjectiveByID(objectiveID)
                    local quest = objective.objectiveParent

                    saveString += "@" + quest.questName + "@#" + objective.objectiveName + "#^" + playerPoints + "^"
                }

                return saveString
            }
        }
    }
}

//string GetStringFromQuests(handle Player)
//
//  This function will create a formatted string
//  that represents the progress for a Player's Quest,
//  Objectives, and points.
//
function GetStringFromQuest(hPlayer, quest)
{
    local player = FindPlayer(hPlayer)

    if (player != null)
    {
        local playerQuestBook = GetPlayerBook(hPlayer)

        if (playerQuestBook != null)
        {
            local playerQuests = playerQuestBook.bookQuests
            local playerObjectives = playerQuestBook.bookObjectives

            if (playerQuests.len() > 0 && playerQuests.find(quest.questID) != null)
            {
                local saveString = ""

                //Create save section for each Objective in Quest
                foreach(objectiveArray in playerObjectives)
                {
                    local objectiveID = objectiveArray[0]
                    local playerPoints = objectiveArray[1]
                    local objective = GetObjectiveByID(objectiveID)
                    local Quest = objective.objectiveParent

                    if (quest == Quest)
                        saveString += "@" + Quest.questName + "@#" + objective.objectiveName + "#^" + playerPoints + "^"
                }

                return saveString
            }
        }
    }
}

//array FilterSaveString(string saveString, string delimiter)
//
//  This function will take a formatted save string and
//  filter the text based on the delimeter value. It will
//  return both the filtered string, as well as the full
//  save string with the filtered value removed.
//
function FilterSaveString(saveString, delimeter)
{
    local strBegin = saveString.find(delimeter)
    local strEnd = saveString.find(delimeter, strBegin + 1)

    //Return valid string
    if (strBegin != null && strEnd != null)
    {
        local strValue = saveString.slice(strBegin + 1, strEnd)
        local newString = saveString.slice(strEnd + 1)

        return [strValue, newString]
    }
}