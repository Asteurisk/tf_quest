local quest =
{
	quest_name = "The Soldier"
	quest_desc = "God bless America!"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Soldier Mission"
		mission_desc = "Complete all Soldier objectives"
		mission_objectives =
		[
			{
				objective_name = "Good Soldier"
				objective_desc = "Get points as Soldier"
				objective_points = 0
				objective_award = 2
				objective_target = 100
				objective_type = "GET_POINTS"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 3]}] //Quester must be Soldier
			},
			{
				objective_name = "God-speed"
				objective_desc = "Kill enemies that are airborne due to an explosion"
				objective_points = 0
				objective_award = 15
				objective_target = 3
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 3]}, {flag_type = "PLAYER_AIRBORNE_EXPLOSION", flag_value = 1}] //Quester must be Soldier; Enemy must have died after becoming airborne via explosive
			}
		]
	}
}

AddQuest(quest)