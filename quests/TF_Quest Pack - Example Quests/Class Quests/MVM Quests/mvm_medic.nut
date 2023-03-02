local quest =
{
	quest_name = "MvM Medic"
	quest_desc = "MvM Quest for Medic"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Medic MvM Mission"
		mission_desc = "Complete all objectives for Medic in MvM"
		mission_objectives =
		[
			{
				objective_name = "Robotic sting"
				objective_desc = "Assist killing robots"
				objective_points = 0
				objective_award = 1
				objective_target = 500
				objective_type = "KILL_PLAYER_ASSIST"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 5]}] //Quester must be Medic
			},
			{
				objective_name = "CNTN-INJECTION"
				objective_desc = "Assist killing robots when sharing an Uber canteen"
				objective_points = 0
				objective_award = 15
				objective_target = 50
				objective_type = "KILL_PLAYER_ASSIST"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 5]}, {flag_type = "PLAYER_INCOND", flag_value = [2, 52]}, {flag_type = "PLAYER_INCOND", flag_value = [0, 52]}] //Quester must be Medic; Quester must be in Cond 52 (Uber canteen); Teammate must be in Cond 52 (Uber canteen)
			},
			{
				objective_name = "Factory Reset"
				objective_desc = "Revive a teammate"
				objective_points = 0
				objective_award = 15
				objective_target = 25
				objective_type = "REVIVE_PLAYER"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 5]}] //Quester must be Medic
			}
		]
	}
}

AddQuest(quest)