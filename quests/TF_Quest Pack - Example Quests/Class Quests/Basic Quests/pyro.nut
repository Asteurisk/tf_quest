local quest =
{
	quest_name = "The Pyro"
	quest_desc = "Mmph-mmph!"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Pyro Mission"
		mission_desc = "Complete all Pyro objectives"
		mission_objectives =
		[
			{
				objective_name = "Mmm-hm."
				objective_desc = "Kill enemies"
				objective_points = 0
				objective_award = 1
				objective_target = 100
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 7]}] //Quester must be Pyro
			},
			{
				objective_name = "MMM-MMM!"
				objective_desc = "Kill enemy Spies"
				objective_points = 0
				objective_award = 10
				objective_target = 3
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 7]}, {flag_type = "PLAYER_CLASS", flag_value = [1, 8]}] //Quester must be Pyro; Enemy must be Spy
			}
		]
	}
}

AddQuest(quest)