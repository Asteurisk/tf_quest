//TF_Quest
//	Team Fortress 2 questing system that recreates the Contracker
//

// debug.nut

local dErrLvl =			// Available error levels
[
	"Critical",			// Major issues
	"Error",			// Important issues
	"Warning",			// Significant issues
	"Notice",			// Significant, but normal, information
	"Info",				// Normal information
	"Debug",			// Low-level, non-significant information
	"Spam"				// Low-level, non-significant information (spams Server console)
]

local dSetLvl = GetSetting("debugLevel") 	// Reporting level
local dPrintTo =							// Where to print
{
	chat = false,
	console = true
}

//void dPrint(int errlvl, string msg)
//
//	This function will print a message with a
//	corresponding error level, such as "Error",
//	"Info", or "Debug".
//
//	Note: Messages can be printed to the console, chatbox, or both.
//
function dPrint(errlvl = null, msg = null)
{
	//Message and ErrorLevel
	if (errlvl != null && msg != null)
	{
		local dMsg = "[ TF_Quest ] (" + dErrLvl[errlvl] + ") -- " + msg
		if (dSetLvl >= errlvl)
		{
			if (dPrintTo.console)
				printl(dMsg)

			if (dPrintTo.chat)
				cPrint(null, dMsg)
		}
	}
	//Message only, no ErrorLevel
	else if (typeof(errlvl) == "string" && msg == null)
	{
		msg = errlvl

		local dMsg = "[ TF_Quest ] (ERROR LEVEL NOT SET) -- " + msg
		if (dPrintTo.console)
			printl(dMsg)

		if (dPrintTo.chat)
			cPrint(null, dMsg)
	}
}

//void cPrint(handle Player, string msg, [bool noBrand])
//
//	This function will print a message to the Player in the
//	chatbox, either with the [TF_QUEST] branding, or without,
//	depending on the value of noBrand.
//
function cPrint(hRecipient, msg, noBrand = null)
{
	if (GetSetting("enableQuestUI"))
	{
		//Message, with [TF_QUEST]
		if (!noBrand)
			msg = "[TF_QUEST]: " + msg

		//Shrink messages over 255 bytes
		if (msg.len() > 255)
			msg = msg.slice(0, 250) + "..."

		ClientPrint(hRecipient, 3, msg)
	}
}

//void hPrint(handle Player, handle game_text, string msg)
//
//	This function will print a message to the Player on
//	their HUD via a game_text entity.
//
function hPrint(hRecipient, hTextEntity, msg)
{
	if (GetSetting("enableQuestUI"))
	{
		//Shrink messages over 255 bytes (~220 chars max from testing?)
		if (msg.len() > 217)
			msg = msg.slice(0, 217) + "..."

		//Edit the current text-field
		hTextEntity.__KeyValueFromString("message", msg)

		//Display the game_text
		EntFireByHandle(hTextEntity, "Display", "", 0.0, hRecipient, hRecipient)
	}
}

//void setDebugLvl(int errlvl)
//
//	This function will set the reporting level for information
//	that gets printed to the console.
//
function setDebugLvl(errlvl)
{
	dSetLvl = errlvl
}