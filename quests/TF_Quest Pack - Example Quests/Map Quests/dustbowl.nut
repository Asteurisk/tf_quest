local quest =
{
	quest_name = "Dustbowl"
	quest_desc = "Conquer the Dustbowl"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Dustbowl Mission"
		mission_desc = "Complete all Dustbowl objectives"
		mission_objectives =
		[
			{
				objective_name = "Contracted killer"
				objective_desc = "Kill enemies"
				objective_points = 0
				objective_award = 1
				objective_target = 100
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "SERVER_MAP", flag_value = "cp_dustbowl"}] //Quester must be playing cp_dustbowl
			},
			{
				objective_name = "Point conquerer"
				objective_desc = "Capture a control point"
				objective_points = 0
				objective_award = 10
				objective_target = 5
				objective_type = "CAPTURE_POINT"
				objective_flags = [{flag_type = "SERVER_MAP", flag_value = "cp_dustbowl"}] //Quester must be playing cp_dustbowl
			},
			{
				objective_name = "Point defender"
				objective_desc = "Defend your control point"
				objective_points = 0
				objective_award = 10
				objective_target = 5
				objective_type = "DEFEND_POINT"
				objective_flags = [{flag_type = "SERVER_MAP", flag_value = "cp_dustbowl"}] //Quester must be playing cp_dustbowl
			}
		]
	}
}

AddQuest(quest)