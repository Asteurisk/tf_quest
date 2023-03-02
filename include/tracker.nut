//TF_Quest
//	Team Fortress 2 questing system that recreates the Contracker
//


//tracker.nut

//Vars
local playerList = []

//Settings
local allowBOTs = GetSetting("allowBOTs")

//table CreateUser(handle Player)
//
//	This function will create a table that
//	stores information about the Player.  This
//	information is widely used throughout TF_Quest
//	to provide much of its functionality.
//
function CreateUser(hPlayer)
{
	local userTable = {
		playerID = playerList.len()
		playerHandle = hPlayer
		playerSteamID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")
		playerName = NetProps.GetPropString(hPlayer, "m_szNetname")
		playerQuestBook = null
		playerPreferences = {
			enableQuestSounds = true
			enableQuestHUD = true
			enableQuestChat = true
		}
	}

	return userTable
}

//void UpdateUserName(handle Player, string name)
//
//	This function will update the Player's stored name
//	in the case that a Player changes their name while
//	being tracked by TF_Quest.
//
function UpdateUserName(hPlayer, name)
{
	local player = FindPlayer(hPlayer)

	if (player != null)
	{
		dPrint(3, "Player (" + player.playerName + ") has changed their name to (" + name + ")")
		player.playerName = name
	}
}

//void TrackPlayer(handle Player)
//
//	This function will setup the Player for tracking
//	by creating a new User table, giving the Player
//	a QuestBook, and loading their Quests
//
function TrackPlayer(hPlayer)
{
	local isPlayerBot = IsPlayerABot(hPlayer)
	local isPlayerTracked = FindPlayer(hPlayer) != null

	if (hPlayer != null && !isPlayerTracked)
	{
		//Filter BOT players
		if (isPlayerBot && !allowBOTs)
		{
			return null
		}

		//Track Player
		local PlayerUser = CreateUser(hPlayer)
		playerList.append(PlayerUser)

		//Give Quest Book
		PlayerUser.playerQuestBook = GiveQuestBook(hPlayer)

		//Load Player's Quests
		LoadQuests(hPlayer)

		dPrint(5, "Now tracking (" + playerList.len() + ") players")
	}
}

//table/int FindPlayer(handle Player, [int returnKey])
//
//	This function will either return the User table
//	for the Player or will return the index of the
//	Player in playerList, if the returnKey value is
//	set to true.
//
function FindPlayer(hPlayer, returnKey = null)
{
	foreach(key, User in playerList)
	{
		if (User.playerHandle == hPlayer)
		{
			if (returnKey)
				return key
			else
				return User
		}
	}
	return null
}

//array FindPlayers()
//
//	This function will return all tracked Players
//
function FindPlayers()
{
	return playerList
}

//void ForgetPlayer(handle Player)
//
//	This function will remove a Player
//	from being tracked.
//
function ForgetPlayer(hPlayer)
{
	local playerIndex = FindPlayer(hPlayer, true)
	local player = FindPlayer(hPlayer)

	if (playerIndex != null)
	{
		playerList.remove(playerIndex)
		dPrint(5, "Now tracking (" + playerList.len() + ") players")
	}
}

//void TrackAllPlayers()
//
//	This function will add all connected Players to the tracker,
//	as long as they have not been added previously.
//
function TrackAllPlayers()
{
	local hPlayer = null

	while (hPlayer = Entities.FindByClassname(hPlayer, "player"))
	{
		local playerNID = NetProps.GetPropString(hPlayer, "m_szNetworkIDString")

		if (playerNID != "")
		{
			TrackPlayer(hPlayer)
		}
	}
}