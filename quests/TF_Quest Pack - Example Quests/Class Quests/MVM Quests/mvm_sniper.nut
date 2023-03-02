local quest =
{
	quest_name = "MvM Sniper"
	quest_desc = "MvM Quest for Sniper"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Sniper MvM Mission"
		mission_desc = "Complete all Sniper MvM objectives"
		mission_objectives =
		[
			{
				objective_name = "Head Spinner"
				objective_desc = "Headshot robots"
				objective_points = 0
				objective_award = 5
				objective_target = 100
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 2]}] //Quester must be Sniper
			}
		]
	}
}

AddQuest(quest)