local quest =
{
	quest_name = "MvM Advanced"
	quest_desc = "Advanced quest for MvM"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Advanced MvM Mission"
		mission_desc = "Complete all Advanced MVM Objectives"
		mission_objectives =
		[
			{
				objective_name = "carrier.Destroy()"
				objective_desc = "Kill robots carrying the bomb"
				objective_points = 0
				objective_award = 1
				objective_target = 500
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_HASITEM", flag_value = 1}] //Enemy must be carrying item
			},
			{
				objective_name = "Mega-Bite"
				objective_desc = "Kill giant robots"
				objective_points = 0
				objective_award = 30
				objective_target = 5
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_NETPROP", flag_value = [1, "bool", "m_bIsMiniBoss", true]}] //Enemy must have their Netprop "m_bIsMiniBoss" set true
			},
			{
				objective_name = "Quicksave"
				objective_desc = "Kill a robot after recently teleporting"
				objective_points = 0
				objective_award = 35
				objective_target = 5
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_INCOND", flag_value = [2, 6]}] //Quester must be in Cond 6 (Teleporter dust)
			}
		]
	}
}

AddQuest(quest)