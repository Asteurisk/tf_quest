local quest =
{
	quest_name = "MvM General"
	quest_desc = "General quest for MvM"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "General MvM Mission"
		mission_desc = "Complete all General MVM Objectives"
		mission_objectives =
		[
			{
				objective_name = "Take that, robot!"
				objective_desc = "Kill robots"
				objective_points = 0
				objective_award = 1
				objective_target = 500
				objective_type = "KILL_PLAYER"
				objective_flags = []
			},
			{
				objective_name = "Brittle-gear Bot"
				objective_desc = "Kill robots while using a Crit canteen"
				objective_points = 0
				objective_award = 10
				objective_target = 50
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_INCOND", flag_value = [2, 34]}] //Quester must be in Cond 34 (Crit canteen)
			},
			{
				objective_name = "Full Reset"
				objective_desc = "Kill a robot while they're taunting"
				objective_points = 0
				objective_award = 50
				objective_target = 5
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_INCOND", flag_value = [1, 7]}] //Enemy must be in Cond 7 (Taunting)
			}
		]
	}
}

AddQuest(quest)