local quest =
{
	quest_name = "The Demoman"
	quest_desc = "Ka-boom!"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Demoman Mission"
		mission_desc = "Complete all Demoman objectives"
		mission_objectives =
		[
			{
				objective_name = "Bad Demoman"
				objective_desc = "Get points as Demoman"
				objective_points = 0
				objective_award = 2
				objective_target = 100
				objective_type = "GET_POINTS"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 4]}] //Quester must be Demoman
			},
			{
				objective_name = "Glue that back together!"
				objective_desc = "Destroy sentry guns"
				objective_points = 0
				objective_award = 5
				objective_target = 5
				objective_type = "DESTROY_BUILDABLE"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 4]}, {flag_type = "PLAYER_BUILDABLE", flag_value = [1, "obj_sentrygun"]}, {flag_type = "PLAYER_CLASS", flag_value = [1, 9]}] //Quester must be Demoman; Enemy must own a buildable (obj_sentrygun); Enemy must be Engineer
			},
			{
				objective_name = "The Scottish Resistance"
				objective_desc = "Kill enemies while Ubered"
				objective_points = 0
				objective_award = 10
				objective_target = 5
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 4]} {flag_type = "PLAYER_INCOND", flag_value = [2, 5]}] //Quester must be Demoman; Quester must be in Cond 5 (Ubercharged)
			}
		]
	}
}

AddQuest(quest)