local quest =
{
	quest_name = "The Sniper"
	quest_desc = "I see you, mate."
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Sniper Mission"
		mission_desc = "Complete all Sniper objectives"
		mission_objectives =
		[
			{
				objective_name = "Boom."
				objective_desc = "Get points as Sniper"
				objective_points = 0
				objective_award = 2
				objective_target = 100
				objective_type = "GET_POINTS"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 2]} {flag_type = "DAMAGE_TYPE", flag_value = 1}] //Quester must be Sniper; Damage done must be Headshot
			},
			{
				objective_name = "Bloody tragic"
				objective_desc = "Dominate enemies"
				objective_points = 0
				objective_award = 15
				objective_target = 2
				objective_type = "DOMINATE_PLAYER"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 2]}] //Quester must be Sniper
			}
		]
	}
}

AddQuest(quest)