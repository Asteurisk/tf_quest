local quest =
{
	quest_name = "MvM Scout"
	quest_desc = "MvM Quest for Scout"
	quest_mode = "quest"
	quest_mission =
	{
		mission_name = "Scout MvM Mission"
		mission_desc = "Complete all MvM Scout objectives"
		mission_objectives =
		[
			{
				objective_name = "Virtual Currency"
				objective_desc = "Collect 1500 cash"
				objective_points = 0
				objective_award = -1
				objective_target = 1500
				objective_type = "PICKUP_MONEY"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 1]}] //Quester must be Scout
			}
		]
	}
}

AddQuest(quest)