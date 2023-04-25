local quest =
{
	quest_name = "The Medic"
	quest_desc = "Oops! That's not medicine!"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Medic Mission"
		mission_desc = "Complete all Medic objectives"
		mission_objectives =
		[
			{
				objective_name = "Zis might sting"
				objective_desc = "Get points as Medic"
				objective_points = 0
				objective_award = 2
				objective_target = 100
				objective_type = "GET_POINTS"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 5]}] //Quester must be Medic
			},
			{
				objective_name = "Uberfest"
				objective_desc = "Assist your Ubered patient"
				objective_points = 0
				objective_award = 10
				objective_target = 5
				objective_type = "KILL_PLAYER_ASSIST"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 5]}, {flag_type = "PLAYER_INCOND", flag_value = [0, 5]}] //Quester must be Medic; Patient must be Ubered
			}
		]
	}
}

AddQuest(quest)