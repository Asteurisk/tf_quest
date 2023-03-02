//TF_Quest
//	Team Fortress 2 questing system that recreates the Contracker
//


//settings.nut


// Feel free to change these settings based on the requirements for your server.
// these settings apply when the script is started.  To apply your settings,
// edit the values from this script and reload TF_Quest.
//
//You can edit these values!
local scriptSettings =
{
    //Quest Settings
    maxQuestsPerPlayer = 10,                         //A player can have this many quests active at once
    savePlayerQuestsDir = "tf_quest/savedata/"      //Directory where player quest progress is saved
    enableQuestSaves = true,                        //Enable or disable Quest progress saving
    enableQuestUI = true,                           //Enable or disable Quest UI (HUD & Chat)
    enableQuestSounds = true,                       //Enable or disable Quest Sounds
    //Party Settings
    allowParties = true,                            //Enable or disable party system
    maxPlayersPerParty = 6,                         //A single party can have this many players
    //Tracker Settings
    allowBOTs = false,                              //If true, BOTs will be tracked like players
    //Command Settings
    allowCommands = true                            //Allow players to use TF_Quest chat commands
    commandDelimeter = "!"                          //Command prefix
    commandBlacklist = []                           //Specific commands to disable for all players
    //Debug Settings
    debugLevel = 6                                  //Specify what TF_Quest prints to console/chat (see "include/debug.nut")
}                                                       //Set value to -1 to disable TF_Quest from printing to console/chat

//Functions

//(varies) GetSetting(string settingName)
//
//  This function will return the value
//  of a setting.
//
function GetSetting(settingName)
    return scriptSettings[settingName]