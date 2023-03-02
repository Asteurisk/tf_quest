local quest =
{
	quest_name = "Offense"
	quest_desc = "Offense Quest"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Offense Mission"
		mission_desc = "Offense Mission"
		mission_objectives =
		[
			{
                objective_name = "Target eliminated"
				objective_desc = "Kill enemies"
				objective_points = 0
				objective_award = 1
				objective_target = 100
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_TEAM", flag_value = [2, 3]}] //Quester must be on team BLU
            },
			{
				objective_name = "All your base are belong to us"
				objective_desc = "Capture an objective"
				objective_points = 0
				objective_award = 5
				objective_target = 10
				objective_type = "CAPTURE_OBJECTIVE"
				objective_flags = [{flag_type = "PLAYER_TEAM", flag_value = [2, 3]}] //Quester must be on team BLU
			}
		]
	}
}

AddQuest(quest)