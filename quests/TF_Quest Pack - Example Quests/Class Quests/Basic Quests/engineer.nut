local quest =
{
	quest_name = "The Engineer"
	quest_desc = "...is Engie-here!"
	quest_mode = "contracker"
	quest_mission =
	{
		mission_name = "Engineer Mission"
		mission_desc = "Complete all Engineer objectives"
		mission_objectives =
		[
			{
				objective_name = "Not pointed at You"
				objective_desc = "Get points as Engineer"
				objective_points = 0
				objective_award = 2
				objective_target = 100
				objective_type = "GET_POINTS"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 9]}, {flag_type = "PLAYER_BUILDABLE", flag_value = [2, "obj_sentrygun"]}] //Quester must be Engineer; Quester must own a buildable (obj_sentrygun)
			},
			{
				objective_name = "Upgraded"
				objective_desc = "Upgrade friendly buildings"
				objective_points = 0
				objective_award = 5
				objective_target = 3
				objective_type = "UPGRADE_BUILDABLE_ASSIST"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 9]}] //Quester must be Engineer
			},
			{
				objective_name = "French Fried"
				objective_desc = "Destroy sappers"
				objective_points = 0
				objective_award = 10
				objective_target = 3
				objective_type = "DESTROY_BUILDABLE"
				objective_flags = [{flag_type = "PLAYER_CLASS", flag_value = [2, 9]}, {flag_type = "PLAYER_BUILDABLE", flag_value = [1, "obj_attachment_sapper"]}] //Quester must be Engineer; Object destroyed must be a sapper owned by an enemy
			}
		]
	}
}

AddQuest(quest)