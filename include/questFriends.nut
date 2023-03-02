//TF_Quest
//	Team Fortress 2 questing system that recreates the Contracker
//


//questFriends.nut

//Settings
 //Friends (Allows two or more Players to work on a Quest)
local allowParties = GetSetting("allowParties")
local maxFriends = GetSetting("maxPlayersPerParty")				//A Player can have this many friends

//Vars
local partyList = []

//Functions

//table CreateParty(handle Player)
//
//	This function creates a table that stores
//	the information required for a Party
//
function CreateParty(hLeader)
{
	local partyTable = {
		partyID = partyList.len()
		partyLeader = hLeader
		partyMembers = []
		partyRequests = []
		partyQuestBook = null
	}

	return partyTable
}

//table AddParty(handle Player)
//
//	This function creates a new Party and
//	automatically joins the Player (Leader)
//	to it.  Party's receive the Leader's QuestBook
//	which is given to each subsequent Member.
//
function AddParty(hLeader)
{
	local leader = FindPlayer(hLeader)

	if (!allowParties)
	{
		cPrint(6, "Creating parties is disabled.")
		return null
	}

	if (leader != null)
	{
		//Player may Create a Party if they are not in one
		if (!PlayerInParty(hLeader))
		{
			//Create Party
			local party = CreateParty(hLeader)
			partyList.append(party)

			//Add Quest Book to Party
			party.partyQuestBook = GetPlayerBookEquipped(hLeader)

			//Add Leader to Party
			JoinParty(party, hLeader)

			//Leader successfully joined Party
			if (PlayerInParty(hLeader, party))
			{
				cPrint(hLeader, "You have created a new party! (Friends can join using '!JoinParty " + leader.playerName + "')")
				dPrint(4, "Player (" + leader.playerName + ") created new Party (" + party.partyID + ")")

				return party
			}
			//Leader did not join Party
			else
			{
				cPrint(hLeader, "There was an issue creating your party. Try again later.")
				DisbandParty(party)
			}
		}
		else
			cPrint(hLeader, "You must leave your party before creating a new one!")
	}
}

//bool JoinParty(table party, handle Player)
//
//	This function performs the action of assigning
//	a Player to a Party.  When the Player joins,
//	they receive the QuestBook of the Party.
//
function JoinParty(party, hMember)
{
	local leader = FindPlayer(party.partyLeader)
	local player = FindPlayer(hMember)
	local members = party.partyMembers
	local playerOnSameTeam = leader.playerHandle.GetTeam() == hMember.GetTeam()

	if (members.len() >= maxFriends)
	{
		cPrint(hMember, "You cannot join this party. There are too many members.")
		return null
	}

	if (player != null)
	{
		if (!PlayerInParty(hMember))
		{
			if (!playerOnSameTeam)
			{
				cPrint(hMember, "Uh-oh! You must be on the same team to join your party!")
				cPrint(party.partyLeader, "Uh-oh! " + player.playerName + " couldn't join because they are not on the same team!")
				return
			}

			//hMember is joining party!
			party.partyMembers.append(hMember)

			//Inform other Party Members of new Member
			foreach(member in members)
				cPrint(member, player.playerName + " has joined the party!")

			dPrint(5, "Player (" + hMember + ") has joined Party ID (" + party.partyID + ")")

			//Give Player Party's QuestBook if needed
			player.playerQuestBook = party.partyQuestBook
			DisplayQuestInfo(hMember)

			cPrint(hMember, "You received your party's quests.")
			return true
		}
		else
		{
			cPrint(hMember, "You must leave your current party before joining another.")
			return false
		}
	}
}

//void LeaveParty(table party, handle Player)
//
//	This function makes a current Party Member
//	leave from the Party.  If the Leader is the one
//	who is leaving, this will disband the Party.
//	The Player who is leaving will receive their
//	personal QuestBook back.
//
function LeaveParty(party, hMember)
{
	local player = FindPlayer(hMember)
	local members = party.partyMembers

	if (player != null)
	{
		if (PlayerInParty(hMember))
		{
			//hMember is leaving party!
			local memberIndex = party.partyMembers.find(hMember)

			if (memberIndex != null)
			{
				party.partyMembers.remove(memberIndex)

				//Inform other Party Members of departing Member
				foreach(member in members)
					cPrint(member, player.playerName + " has left the party!")

				if (party.partyLeader == hMember)
					DisbandParty(party)

				//Give Player their old QuestBook
				player.playerQuestBook = GetPlayerBook(hMember)
				DisplayQuestProgress(hMember)

				//Inform Player of departure
				cPrint(hMember, "You left the party.")
				dPrint(5, "Player (" + hMember + ") has left Party ID (" + party.partyID + ")")
			}
		}
		else
			cPrint(hMember, "You are not in a party.")
	}
}

//void DisbandParty(table party)
//
//	This function will delete a Party and
//	cause all Members to leave.
//
function DisbandParty(party)
{
	local members = party.partyMembers
	local hLeader = party.partyLeader

	local leader = FindPlayer(hLeader)

	//Inform Members of disband; Give Members new Quest Book
	foreach(hMember in members)
	{
		local member = FindPlayer(hMember)

		//Remove all Members except Leader
		if (member != null && hMember != party.partyLeader)
		{
			LeaveParty(party, hMember)
		}

		//Remove Leader
		if (leader != null)
		{
			leader.playerQuestBook = GetPlayerBook(hLeader)
			DisplayQuestProgress(hLeader)
		}

		cPrint(hMember, "Party has disbanded!")
	}

	//Cleanup
	foreach(key, Party in partyList)
	{
		if (Party.partyID == party.partyID)
		{
			partyList.remove(key)
			dPrint(5, "Party (" + party.partyID + ") has been disbanded!")
		}
	}
}

//bool PlayerInParty(handle Player, [table party])
//
//	This function will return true if the Player value
//	matches a Player that is currently within any party.
//	if the optional party value is set, it will check,
//	and return true, if the Player is in a specific Party.
//
function PlayerInParty(hPlayer, party = null)
{
	//Return if Player is in any Party
	local playerParty = GetPartyWithPlayer(hPlayer)

	if (playerParty != null)
	{
		//Return if Player is in any Party
		if (party == null)
			return true
		//Return if Player is in specific Party
		else if (playerParty.partyID == party.partyID)
			return true
		else
			return false
	}
}

//table GetPartyWithPlayer(handle Player)
//
//	This function will return a Party that
//	the Player is currently in, if any.
//
function GetPartyWithPlayer(hPlayer)
{
	foreach(key, party in partyList)
	{
		if (party.partyMembers.find(hPlayer) != null)
		{
			return partyList[key]
		}
	}
}

//void SendJoinRequest(table party, handle Player)
//
//	This function will add the Player to the Party's
//	requests array and send a message to the Party Leader
//	that a Player wishes to join their Party.
//
function SendJoinRequest(party, hPlayer)
{
	local player = FindPlayer(hPlayer)
	local partyLeader = party.partyLeader
	local playerLeader = FindPlayer(partyLeader)

	if (player != null)
	{
		if (!PlayerInParty(hPlayer))
		{
			party.partyRequests.append(hPlayer)

			//Send message to Party Leader
			cPrint(partyLeader, player.playerName + " has requested to join your party. (!Accept " + player.playerName + " to accept)")

			//Send message to requester
			cPrint(hPlayer, playerLeader.playerName + " has received your request to join!")

			//BOTs auto-accept join requests
			if (IsPlayerABot(partyLeader))
				if (hPlayer.GetTeam() == partyLeader.GetTeam())
					AcceptJoinRequest(party, hPlayer)
				else
					RejectJoinRequest(party, hPlayer)
		}
		else
			cPrint(hPlayer, "You must leave your current party before sending a request.")
	}
}

//void AcceptJoinRequest(table party, handle Player)
//
//	This function will join the Invitee to the Party
//	and will remove the Invitee from the Party's
//	requests array.
//
function AcceptJoinRequest(party, hPlayer)
{
	local player = FindPlayer(hPlayer)

	if (player != null)
	{
		if (!PlayerInParty(hPlayer))
		{
			local requestIndex = party.partyRequests.find(hPlayer)

			if (requestIndex != null)
			{
				//Add Requester to Member List
				local playerAccepted = JoinParty(party, hPlayer)

				if (playerAccepted)
				{
					party.partyRequests.remove(requestIndex)
				}
			}
		}
		else
			cPrint(party.partyLeader, "Uh-oh! " + player.playerName + " cannot join your party.  They are already in another party!")
	}
}

//void RejectJoinRequest(table party, handle Player)
//
//	This function will remove the Invitee from
//	the Party's requests array, and will inform the
//	Invitee that they cannot join the Party.
//
function RejectJoinRequest(party, hPlayer)
{
	local player = FindPlayer(hPlayer)

	if (player != null)
	{
		local requestIndex = party.partyRequests.find(hPlayer)

		if (requestIndex != null)
		{
			//Remove Requester from Request List
			party.partyRequests.remove(requestIndex)

			//Inform Party Leader
			cPrint(party.partyLeader, "You rejected the request.")

			//Inform Requestee
			cPrint(hPlayer, "Your request to join was denied!")
		}
	}
}