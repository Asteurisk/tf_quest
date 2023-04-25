local quest =
{
	quest_name = "The Scout"
	quest_desc = "I AM THE SCOUT HERE!"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Scout Mission"
		mission_desc = "Complete all Scout objectives"
		mission_objectives =
		[
			{
				objective_name = "I'm back, dummy!"
				objective_desc = "Get points as Scout"
				objective_points = 0
				objective_award = 2
				objective_target = 100
				objective_type = "GET_POINTS"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 1]}] //Quester must be Scout
			},
			{
				objective_name = "Got your point!"
				objective_desc = "Capture enemy Objectives"
				objective_points = 0
				objective_award = 10
				objective_target = 5
				objective_type = "CAPTURE_OBJECTIVE"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 1]}] //Quester must be Scout
			}
		]
	}
}

AddQuest(quest)
