local quest =
{
	quest_name = "Defense"
	quest_desc = "Defense Quest"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Defense Mission"
		mission_desc = "Defense Mission"
		mission_objectives =
		[
            {
                objective_name = "Target eliminated"
				objective_desc = "Kill enemies"
				objective_points = 0
				objective_award = 1
				objective_target = 100
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_TEAM", flag_value = [2, 2]}] //Quester must be on team RED
            },
			{
				objective_name = "This objective is mine!"
				objective_desc = "Defend your objective"
				objective_points = 0
				objective_award = 10
				objective_target = 5
				objective_type = "DEFEND_OBJECTIVE"
				objective_flags = [{flag_type = "PLAYER_TEAM", flag_value = [2, 2]}] //Quester must be on team RED
			}
		]
	}
}

AddQuest(quest)