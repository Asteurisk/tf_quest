local quest =
{
	quest_name = "The Heavy"
	quest_desc = "Heavy likes this."
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Heavy Mission"
		mission_desc = "Complete all Heavy objectives"
		mission_objectives =
		[
			{
				objective_name = "Ya-da-da-da-da-da-da-da!"
				objective_desc = "Kill enemies"
				objective_points = 0
				objective_award = 1
				objective_target = 100
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 6]}] //Quester must be Heavy
			},
			{
				objective_name = "Team time, Doctor"
				objective_desc = "Kill enemies while Ubered"
				objective_points = 0
				objective_award = 10
				objective_target = 5
				objective_type = "KILL_PLAYER"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 6]}, {flag_type = "PLAYER_INCOND", flag_value = [2, 5]}] //Quester must be Heavy; Quester must have Cond 5 (Ubercharged)
			},
			{
				objective_name = "Itty-bitty Baby Toys"
				objective_desc = "Destroy sentry guns"
				objective_points = 0
				objective_award = 10
				objective_target = 3
				objective_type = "DESTROY_BUILDABLE"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 6]}, {flag_type = "PLAYER_BUILDABLE", flag_value = [1, "obj_sentrygun"]}] //Quester must be Heavy; Object destroyed must be a Sentrygun owned by an enemy
			}
		]
	}
}

AddQuest(quest)