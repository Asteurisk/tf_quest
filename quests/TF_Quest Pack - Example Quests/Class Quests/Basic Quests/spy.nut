local quest =
{
	quest_name = "The Spy"
	quest_desc = "I feel tres bon!"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Spy Mission"
		mission_desc = "Complete all Spy objectives"
		mission_objectives =
		[
			{
				objective_name = "Hidden in Plain Sight"
				objective_desc = "Kill enemies"
				objective_points = 0
				objective_award = 5
				objective_target = 100
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 8]}] //Quester must be Spy
			},
			{
				objective_name = "Doctor No!"
				objective_desc = "Kill 3 Medics"
				objective_points = 0
				objective_award = 15
				objective_target = 3
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 8]}, {flag_type = "PLAYER_CLASS", flag_value = [1, 5]}] //Quester must be Spy; Enemy must be Medic
			},
			{
				objective_name = "Your little Toys"
				objective_desc = "Destroy 5 Engineer's building"
				objective_points = 0
				objective_award = 10
				objective_target = 5
				objective_type = "DESTROY_BUILDABLE"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 8]}, {flag_type = "PLAYER_BUILDABLE", flag_value = [1, ["obj_sentrygun", "obj_dispenser", "obj_teleporter"]]}] //Quester must be Spy; Enemy must own a buildable (obj_sentrygun, obj_dispenser, obj_teleporter)
			}
		]
	}
}

AddQuest(quest)