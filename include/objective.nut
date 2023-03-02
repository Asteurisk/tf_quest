//TF_Quest
//	Team Fortress 2 questing system that recreates the Contracker
//

//Objective Passed Parameters
//	PLAYER_FRIENDLY 		-- Player on the same team
//	PLAYER_ENEMY			-- Player on the opposing team
//	ENTITY_BUILDABLE		-- Entity classname for a Player buildable (Engineer's buildings, Spy's sapper)
//	ENTITY_OTHER			-- Entity classname for any type of entity
//	DAMAGE_TYPE			-- Integer value mapping to a specific type of damage, see ETFDmgCustom

//objective.nut

//Vars

  //Objective Types
local objectiveTypes =
[
	"KILL_PLAYER",
	"KILL_PLAYER_ASSIST",
	"KILL_ENVIRONMENTAL",
	"KILL_CAPPER",
	"KILL_ROBOT_DELIVERING_BOMB",
	"KILL_SENTRYBUSTER",
	"SURVIVE_KILL",
	"DOMINATE_PLAYER",
	"STUN_PLAYER",
	"DAMAGE_PLAYER",
	"DAMAGE_BOSS",
	"PREVENT_DAMAGE",
	"PREVENT_DAMAGE_MEDISHIELD",
	"HEAL_PLAYER",
	"HEAL_BUILDABLE",
	"REVIVE_PLAYER",
	"IGNITE_PLAYER",
	"EXTINGUISH_PLAYER",
	"TELEPORT_PLAYER",
	"INVUL_PLAYER",
	"STEAL_SANDVICH",
	"SHARE_CANTEEN",
	"BUILD_BUILDABLE",
	"UPGRADE_BUILDABLE",
	"UPGRADE_BUILDABLE_ASSIST",
	"DESTROY_BUILDABLE",
	"DESTROY_BUILDABLE_ASSIST",
	"DESTROY_RAZORBACK",
	"DESTROY_TANK",
	"SAPPED_BUILDABLE",
	"RESET_BOMB",
	"RESET_BOMB_DEPLOY",
	"WIN_GAME",
	"WIN_GAME_MVP",
	"WIN_WAVE",
	"DEFEND_FLAG",
	"DEFEND_POINT",
	"DEFEND_OBJECTIVE",
	"PICKUP_FLAG",
	"PICKUP_CRUMPKIN",
	"PICKUP_GIFT",
	"PICKUP_MONEY",
	"CAPTURE_FLAG",
	"CAPTURE_POINT",
	"CAPTURE_OBJECTIVE"
]

//Functions
//bool ProgressObjective(handle Player, table objective, table objectiveParams)
//
//	Each Objective in a Quest has a single objectiveType, which corresponds
//	to an event that occurs within play.  If our objectiveType is "KILL_PLAYER",
//	that will match against our objectiveTypes array and call the function
//	ProcessObjectiveFlags() to proceed with further inspection.
//
function ProgressObjective(hPlayer, objective, objectiveParams)
{
	local objectiveProgressed = false
	local objectiveType = objective.objectiveType

	//Check Objective flags
	if (objectiveTypes.find(objectiveType) != null)
		objectiveProgressed = ProcessObjectiveFlags(hPlayer, objective, objectiveParams)
	else
		//If this happens, a mistake was made in the questScript!
		dPrint(2, "objectiveType in objective not found, missing type (" + objectiveType + ")")

	if (objectiveProgressed)
		return true
	else
		return false
}


//bool ProcessObjectiveFlags(handle Player, table Objective, table objectiveParams)
//
//	Each Objective in a Quest has a list of objectiveFlags that we use to
//	determine if something is true or valid for the event that occured.
//
//	This function returns true or false; true if all flags for the objective
//	have passed inspection, or false if even a single flag has failed.
//
function ProcessObjectiveFlags(hPlayer, objective, objectiveParams)
{
	local objectiveFlags = objective.objectiveFlags
	local passAmt = 0

	foreach(key, objectiveFlagArray in objectiveFlags)
	{
		local objectiveFlagType = objectiveFlagArray.flag_type
		local objectiveFlagValue = objectiveFlagArray.flag_value
		local passFlags = false	//If flags has passed for objective check

		switch (objectiveFlagType)
		{
			case "PLAYER_CLASS" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)
				local flagTeam = objectiveFlagValue[0]

				if (flagTeam == 2 && "PLAYER_SELF" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_SELF")
					local selfClass = objectiveParams.PLAYER_SELF.GetPlayerClass()
					local flagTeam = objectiveFlagValue[0]
					local flagClass = objectiveFlagValue[1]

					//Check Single class
					if (typeof(flagClass) == "integer")
					{
						if (selfClass == flagClass || flagClass == 0)
							passFlags = true
					}
					//Check Multiple classes
					else if (typeof(flagClass) == "array")
					{
						foreach(valueFlagClass in flagClass)
						{
							if (selfClass == valueFlagClass || flagClass == 0)
								passFlags = true
						}
					}
				}
				else if (flagTeam == 0 && "PLAYER_FRIENDLY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_FRIENDLY")
					local friendlyClass = objectiveParams.PLAYER_FRIENDLY.GetPlayerClass()
					local flagTeam = objectiveFlagValue[0]
					local flagClass = objectiveFlagValue[1]

					if ("PLAYER_SELF" in objectiveParams)
					{
						local isFriendlySelf = objectiveParams.PLAYER_SELF == objectiveParams.PLAYER_FRIENDLY

						//Check flag only if PLAYER_FRIENDLY != PLAYER_SELF
						if (!isFriendlySelf)
						{
							//Check Single class
							if (typeof(flagClass) == "integer")
							{
								if (friendlyClass == flagClass || flagClass == 0)
									passFlags = true
							}
							//Check Multiple classes
							else if (typeof(flagClass) == "array")
							{
								foreach(valueFlagClass in flagClass)
								{
									if (friendlyClass == valueFlagClass || flagClass == 0)
										passFlags = true
								}
							}
						}
					}
				}
				else if (flagTeam == 1 && "PLAYER_ENEMY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_ENEMY")
					local enemyClass = objectiveParams.PLAYER_ENEMY.GetPlayerClass()
					local flagTeam = objectiveFlagValue[0]
					local flagClass = objectiveFlagValue[1]

					//Check Single class
					if (typeof(flagClass) == "integer")
					{
						if (enemyClass == flagClass || flagClass == 0)
							passFlags = true
					}
					//Check Multiple classes
					else if (typeof(flagClass) == "array")
					{
						foreach(valueFlagClass in flagClass)
						{
							if (enemyClass == valueFlagClass || flagClass == 0)
								passFlags = true
						}
					}
				}
			break

			case "PLAYER_TEAM" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)
				local flagTeam = objectiveFlagValue[0]

				if (flagTeam == 2 && "PLAYER_SELF" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_SELF")
					local selfGameTeam = objectiveParams.PLAYER_SELF.GetTeam()
					local flagGameTeam = objectiveFlagValue[1]

					if (selfGameTeam == flagGameTeam)
						passFlags = true
				}
				else if (flagTeam == 0 && "PLAYER_FRIENDLY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_FRIENDLY")
					local friendlyGameTeam = objectiveParams.PLAYER_FRIENDLY.GetTeam()
					local flagGameTeam = objectiveFlagValue[1]

					if (friendlyGameTeam == flagGameTeam)
						passFlags = true
				}
				else if (flagTeam == 1 && "PLAYER_ENEMY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_ENEMY")
					local enemyGameTeam = objectiveParams.PLAYER_ENEMY.GetTeam()
					local flagGameTeam = objectiveFlagValue[1]

					if (enemyGameTeam == flagGameTeam)
						passFlags = true
				}
			break

			case "PLAYER_BUTTONS" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)
				local flagTeam = objectiveFlagValue[0]

				if (flagTeam == 2 && "PLAYER_SELF" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_SELF")
					local flagButtons = objectiveFlagValue[1]

					if (NetProps.GetPropInt(objectiveParams.PLAYER_SELF, "m_nButtons") == flagButtons)
						passFlags = true
				}
				else if (flagTeam == 0 && "PLAYER_FRIENDLY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_FRIENDLY")

					if (NetProps.GetPropInt(objectiveParams.PLAYER_FRIENDLY, "m_nButtons") == flagButtons)
						passFlags = true
				}
				else if (flagTeam == 1 && "PLAYER_ENEMY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_ENEMY")

					if (NetProps.GetPropInt(objectiveParams.PLAYER_ENEMY, "m_nButtons") == flagButtons)
						passFlags = true
				}
			break

			case "PLAYER_WEAPON" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)
				local flagTeam = objectiveFlagValue[0]

				if (flagTeam == 2 && "PLAYER_SELF" in objectiveParams)
				{
					if ("ENTITY_WEAPON" in objectiveParams)
					{
						dPrint(6, "Found PLAYER_SELF")

						local selfWeaponName = objectiveParams.ENTITY_WEAPON
						local flagWeaponName = objectiveFlagValue[1]

						if (selfWeaponName != null)
						{
							//Check for Single weapon
							if (typeof(flagWeaponName) == "string")
							{
								if (flagWeaponName == selfWeaponName)
									passFlags = true
							}
							//Check for Multiple weapons
							else if (typeof (flagWeaponName) == "array")
							{
								foreach(valueWeaponName in flagWeaponName)
								{
									if (valueWeaponName == selfWeaponName)
										passFlags = true
								}
							}
						}
					}
				}
				else if (flagTeam == 0 && "PLAYER_FRIENDLY" in objectiveParams)
				{
					if ("ENTITY_WEAPON" in objectiveParams)
					{
						dPrint(6, "Found PLAYER_FRIENDLY")

						local friendlyWeaponName = objectiveParams.ENTITY_WEAPON
						local flagWeaponName = objectiveFlagValue[1]

						if (friendlyWeaponName != null)
						{
							//Check for Single weapon
							if (typeof(flagWeaponName) == "string")
							{
								if (flagWeaponName == friendlyWeaponName)
									passFlags = true
							}
							//Check for Multiple weapons
							else if (typeof (flagWeaponName) == "array")
							{
								foreach(valueWeaponName in flagWeaponName)
								{
									if (valueWeaponName == friendlyWeaponName)
										passFlags = true
								}
							}
						}
					}
				}
				else if (flagTeam == 1 && "PLAYER_ENEMY" in objectiveParams)
				{
					if ("ENTITY_WEAPON" in objectiveParams)
					{
						dPrint(6, "Found PLAYER_ENEMY")

						local enemyWeaponName = objectiveParams.ENTITY_WEAPON
						local flagWeaponName = objectiveFlagValue[1]

						if (enemyWeaponName != null)
						{
							//Check for Single weapon
							if (typeof(flagWeaponName) == "string")
							{
								if (flagWeaponName == enemyWeaponName)
									passFlags = true
							}
							//Check for Multiple weapons
							else if (typeof (flagWeaponName) == "array")
							{
								foreach(valueWeaponName in flagWeaponName)
								{
									if (valueWeaponName == enemyWeaponName)
										passFlags = true
								}
							}
						}
					}
				}
			break

			case "PLAYER_BUILDABLE" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)

				if ("ENTITY_BUILDABLE" in objectiveParams)
				{
					local flagTeam = objectiveFlagValue[0]

					if (flagTeam == 2 && "PLAYER_SELF" in objectiveParams)
					{
						dPrint(6, "Found PLAYER_SELF")
						local buildableOwner = NetProps.GetPropEntity(objectiveParams.ENTITY_BUILDABLE, "m_hBuilder")
						local flagBuildableClassname = objectiveFlagValue[1]

						//Check for Single buildable
						if (typeof(flagBuildableClassname) == "string")
						{
							local isChildOfBuildable = objectiveParams.ENTITY_BUILDABLE.GetOwner() != null

							//Entity passed has Owner
							if (isChildOfBuildable)
							{
								local parentClassname = objectiveParams.ENTITY_BUILDABLE.GetOwner().GetClassname()

								//Owner entity matches Objective's flag value
								if (parentClassname == flagBuildableClassname)
								{
									//Loop all entities of type flagBuildableClassname
									local buildable

									while (buildable = Entities.FindByClassname(buildable, flagBuildableClassname))
									{
										buildableOwner = NetProps.GetPropEntity(buildable, "m_hBuilder")

										if (buildableOwner == objectiveParams.PLAYER_SELF)
											passFlags = true
									}
								}
							}
							//Entity passed has null Owner
							else if (flagBuildableClassname == objectiveParams.ENTITY_BUILDABLE.GetClassname())
							{
								if (buildableOwner == objectiveParams.PLAYER_SELF)
									passFlags = true
							}
						}
						//Check for Multiple buildables
						else if (typeof(flagBuildableClassname) == "array")
						{
							//Loop through all strings in flagBuildableClassname
							foreach(flagClassname in flagBuildableClassname)
							{
								local isChildOfBuildable = objectiveParams.ENTITY_BUILDABLE.GetOwner() != null

								//Entity passed has Owner
								if (isChildOfBuildable)
								{
									local parentClassname = objectiveParams.ENTITY_BUILDABLE.GetOwner().GetClassname()

									//Owner entity matches Objective's flag value
									if (parentClassname == flagClassname)
									{
										//Loop all entities of type flagClassname
										local buildable

										while (buildable = Entities.FindByClassname(buildable, flagClassname))
										{
											buildableOwner = NetProps.GetPropEntity(buildable, "m_hBuilder")

											if (buildableOwner == objectiveParams.PLAYER_SELF)
												passFlags = true
										}
									}
								}
								//Entity passed has null Owner
								else if (flagClassname == objectiveParams.ENTITY_BUILDABLE.GetClassname())
								{
									if (buildableOwner == objectiveParams.PLAYER_SELF)
										passFlags = true
								}
							}
						}
					}
					else if (flagTeam == 0 && "PLAYER_FRIENDLY" in objectiveParams)
					{
						dPrint(6, "Found PLAYER_FRIENDLY")
						local buildableOwner = NetProps.GetPropEntity(objectiveParams.ENTITY_BUILDABLE, "m_hBuilder")
						local flagBuildableClassname = objectiveFlagValue[1]

						//Check for Single buildable
						if (typeof(flagBuildableClassname) == "string")
						{
							local isChildOfBuildable = objectiveParams.ENTITY_BUILDABLE.GetOwner() != null

							//Entity passed has Owner
							if (isChildOfBuildable)
							{
								local parentClassname = objectiveParams.ENTITY_BUILDABLE.GetOwner().GetClassname()

								//Owner entity matches Objective's flag value
								if (parentClassname == flagBuildableClassname)
								{
									//Loop all entities of type flagBuildableClassname
									local buildable

									while (buildable = Entities.FindByClassname(buildable, flagBuildableClassname))
									{
										buildableOwner = NetProps.GetPropEntity(buildable, "m_hBuilder")

										if (buildableOwner == objectiveParams.PLAYER_FRIENDLY)
											passFlags = true
									}
								}
							}
							//Entity passed has null Owner
							else if (flagBuildableClassname == objectiveParams.ENTITY_BUILDABLE.GetClassname())
							{
								if (buildableOwner == objectiveParams.PLAYER_FRIENDLY)
									passFlags = true
							}
						}
						//Check for Multiple buildables
						else if (typeof(flagBuildableClassname) == "array")
						{
							//Loop through all strings in flagBuildableClassname
							foreach(flagClassname in flagBuildableClassname)
							{
								local isChildOfBuildable = objectiveParams.ENTITY_BUILDABLE.GetOwner() != null

								//Entity passed has Owner
								if (isChildOfBuildable)
								{
									local parentClassname = objectiveParams.ENTITY_BUILDABLE.GetOwner().GetClassname()

									//Owner entity matches Objective's flag value
									if (parentClassname == flagClassname)
									{
										//Loop all entities of type flagClassname
										local buildable

										while (buildable = Entities.FindByClassname(buildable, flagClassname))
										{
											buildableOwner = NetProps.GetPropEntity(buildable, "m_hBuilder")

											if (buildableOwner == objectiveParams.PLAYER_FRIENDLY)
												passFlags = true
										}
									}
								}
								//Entity passed has null Owner
								else if (flagClassname == objectiveParams.ENTITY_BUILDABLE.GetClassname())
								{
									if (buildableOwner == objectiveParams.PLAYER_FRIENDLY)
										passFlags = true
								}
							}
						}
					}
					else if (flagTeam == 1 && "PLAYER_ENEMY" in objectiveParams)
					{
						dPrint(6, "Found PLAYER_ENEMY")
						local buildableOwner = NetProps.GetPropEntity(objectiveParams.ENTITY_BUILDABLE, "m_hBuilder")
						local flagBuildableClassname = objectiveFlagValue[1]

						//Check for Single buildable
						if (typeof(flagBuildableClassname) == "string")
						{
							local isChildOfBuildable = objectiveParams.ENTITY_BUILDABLE.GetOwner() != null

							//Entity passed has Owner
							if (isChildOfBuildable)
							{
								local parentClassname = objectiveParams.ENTITY_BUILDABLE.GetOwner().GetClassname()

								//Owner entity matches Objective's flag value
								if (parentClassname == flagBuildableClassname)
								{
									//Loop all entities of type flagBuildableClassname
									local buildable

									while (buildable = Entities.FindByClassname(buildable, flagBuildableClassname))
									{
										buildableOwner = NetProps.GetPropEntity(buildable, "m_hBuilder")

										if (buildableOwner == objectiveParams.PLAYER_ENEMY)
											passFlags = true
									}
								}
							}
							//Entity passed has null Owner
							else if (flagBuildableClassname == objectiveParams.ENTITY_BUILDABLE.GetClassname())
							{
								if (buildableOwner == objectiveParams.PLAYER_ENEMY)
									passFlags = true
							}
						}
						//Check for Multiple buildables
						else if (typeof(flagBuildableClassname) == "array")
						{
							//Loop through all strings in flagBuildableClassname
							foreach(flagClassname in flagBuildableClassname)
							{
								local isChildOfBuildable = objectiveParams.ENTITY_BUILDABLE.GetOwner() != null

								//Entity passed has Owner
								if (isChildOfBuildable)
								{
									local parentClassname = objectiveParams.ENTITY_BUILDABLE.GetOwner().GetClassname()

									//Owner entity matches Objective's flag value
									if (parentClassname == flagClassname)
									{
										//Loop all entities of type flagClassname
										local buildable

										while (buildable = Entities.FindByClassname(buildable, flagClassname))
										{
											buildableOwner = NetProps.GetPropEntity(buildable, "m_hBuilder")

											if (buildableOwner == objectiveParams.PLAYER_ENEMY)
												passFlags = true
										}
									}
								}
								//Entity passed has null Owner
								else if (flagClassname == objectiveParams.ENTITY_BUILDABLE.GetClassname())
								{
									if (buildableOwner == objectiveParams.PLAYER_ENEMY)
										passFlags = true
								}
							}
						}
					}
				}
			break

			case "PLAYER_INCOND" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)
				local flagTeam = objectiveFlagValue[0]

				if (flagTeam == 2 && "PLAYER_SELF" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_SELF")
					local flagCond = objectiveFlagValue[1]
					local selfPlayer = objectiveParams.PLAYER_SELF

					if (selfPlayer.InCond(flagCond))
						passFlags = true
				}
				else if (flagTeam == 0 && "PLAYER_FRIENDLY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_FRIENDLY")
					local flagCond = objectiveFlagValue[1]
					local friendlyPlayer = objectiveParams.PLAYER_FRIENDLY

					if (friendlyPlayer.InCond(flagCond))
						passFlags = true
				}
				else if (flagTeam == 1 && "PLAYER_ENEMY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_ENEMY")
					local flagCond = objectiveFlagValue[1]
					local enemyPlayer = objectiveParams.PLAYER_ENEMY

					if (enemyPlayer.InCond(flagCond))
						passFlags = true
				}
			break

			case "PLAYER_HASITEM" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)
				local flagTeam = objectiveFlagValue[0]

				if (flagTeam == 2 && "PLAYER_SELF" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_SELF")
					local selfHasItem = objectiveParams.PLAYER_SELF.HasItem()

					if (selfHasItem)
						passFlags = true
				}
				else if (flagTeam == 0 && "PLAYER_FRIENDLY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_FRIENDLY")
					local friendlyHasItem = objectiveParams.PLAYER_FRIENDLY.HasItem()

					if (friendlyHasItem)
						passFlags = true
				}
				else if (flagTeam == 1 && "PLAYER_ENEMY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_ENEMY")
					local enemyHasItem = objectiveParams.PLAYER_ENEMY.HasItem()

					if (enemyHasItem)
						passFlags = true
				}
			break

			case "PLAYER_AIRBORNE_EXPLOSION" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)
				local flagTeam = objectiveFlagValue

				if (flagTeam == 2 && "PLAYER_SELF" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_SELF")
					local selfPlayer = objectiveParams.PLAYER_SELF

					if (selfPlayer.InAirDueToExplosion())
						passFlags = true
				}
				else if (flagTeam == 0 && "PLAYER_FRIENDLY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_FRIENDLY")
					local friendlyPlayer = objectiveParams.PLAYER_FRIENDLY

					if (friendlyPlayer.InAirDueToExplosion())
						passFlags = true
				}
				else if (flagTeam == 1 && "PLAYER_ENEMY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_ENEMY")
					local enemyPlayer = objectiveParams.PLAYER_ENEMY

					if (enemyPlayer.InAirDueToExplosion())
						passFlags = true
				}
			break

			case "PLAYER_AIRBORNE_KNOCKBACK" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)
				local flagTeam = objectiveFlagValue

				if (flagTeam == 2 && "PLAYER_SELF" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_SELF")
					local selfPlayer = objectiveParams.PLAYER_SELF

					if (selfPlayer.InAirDueToKnockback())
						passFlags = true
				}
				else if (flagTeam == 0 && "PLAYER_FRIENDLY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_FRIENDLY")
					local friendlyPlayer = objectiveParams.PLAYER_FRIENDLY

					if (friendlyPlayer.InAirDueToKnockback())
						passFlags = true
				}
				else if (flagTeam == 1 && "PLAYER_ENEMY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_ENEMY")
					local enemyPlayer = objectiveParams.PLAYER_ENEMY

					if (enemyPlayer.InAirDueToKnockback())
						passFlags = true
				}
			break

			case "PLAYER_NETPROP" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)
				local flagTeam = objectiveFlagValue[0]

				if (flagTeam == 2 && "PLAYER_SELF" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_SELF")
					local propType = objectiveFlagValue[1]
					local propName = objectiveFlagValue[2]
					local propValue = objectiveFlagValue[3]

					if (NetProps.GetPropType(objectiveParams.PLAYER_SELF, propName) == propType)
					{
						switch (propType)
						{
							case "bool" :
								if (NetProps.GetPropBool(objectiveParams.PLAYER_SELF, propName) == propValue)
									passFlags = true
							break

							case "float" :
								if (NetProps.GetPropFloat(objectiveParams.PLAYER_SELF, propName) == propValue)
									passFlags = true
							break

							case "integer" :
								if (NetProps.GetPropInt(objectiveParams.PLAYER_SELF, propName) == propValue)
									passFlags = true
							break

							case "string" :
								if (NetProps.GetPropString(objectiveParams.PLAYER_SELF, propName) == propValue)
									passFlags = true
							break

							case "Vector" :
								if (NetProps.GetPropVector(objectiveParams.PLAYER_SELF, propName) == propValue)
									passFlags = true
							break
						}
					}
				}
				else if (flagTeam == 0 && "PLAYER_FRIENDLY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_FRIENDLY")
					local propType = objectiveFlagValue[1]
					local propName = objectiveFlagValue[2]
					local propValue = objectiveFlagValue[3]

					if (NetProps.GetPropType(objectiveParams.PLAYER_FRIENDLY, propName) == propType)
					{
						switch (propType)
						{
							case "bool" :
								if (NetProps.GetPropBool(objectiveParams.PLAYER_FRIENDLY, propName) == propValue)
									passFlags = true
							break

							case "float" :
								if (NetProps.GetPropFloat(objectiveParams.PLAYER_FRIENDLY, propName) == propValue)
									passFlags = true
							break

							case "integer" :
								if (NetProps.GetPropInt(objectiveParams.PLAYER_FRIENDLY, propName) == propValue)
									passFlags = true
							break

							case "string" :
								if (NetProps.GetPropString(objectiveParams.PLAYER_FRIENDLY, propName) == propValue)
									passFlags = true
							break

							case "Vector" :
								if (NetProps.GetPropVector(objectiveParams.PLAYER_FRIENDLY, propName) == propValue)
									passFlags = true
							break
						}
					}
				}
				else if (flagTeam == 1 && "PLAYER_ENEMY" in objectiveParams)
				{
					dPrint(6, "Found PLAYER_ENEMY")
					local propType = objectiveFlagValue[1]
					local propName = objectiveFlagValue[2]
					local propValue = objectiveFlagValue[3]

					if (NetProps.GetPropType(objectiveParams.PLAYER_ENEMY, propName) == propType)
					{
						switch (propType)
						{
							case "bool" :
								if (NetProps.GetPropBool(objectiveParams.PLAYER_ENEMY, propName) == propValue)
									passFlags = true
							break

							case "float" :
								if (NetProps.GetPropFloat(objectiveParams.PLAYER_ENEMY, propName) == propValue)
									passFlags = true
							break

							case "integer" :
								if (NetProps.GetPropInt(objectiveParams.PLAYER_ENEMY, propName) == propValue)
									passFlags = true
							break

							case "string" :
								if (NetProps.GetPropString(objectiveParams.PLAYER_ENEMY, propName) == propValue)
									passFlags = true
							break

							case "Vector" :
								if (NetProps.GetPropVector(objectiveParams.PLAYER_ENEMY, propName) == propValue)
									passFlags = true
							break
						}
					}
				}

			case "DAMAGE_TYPE" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)

				if ("DAMAGE_TYPE" in objectiveParams)
				{
					local flagType = objectiveFlagValue

					if (flagType == objectiveParams.DAMAGE_TYPE)
						passFlags = true
				}
			break

			case "ROUND_STATE" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)

				local flagState = objectiveFlagValue

				if (GetRoundState() == flagState)
					passFlags = true
			break

			case "SERVER_MAP" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)

				local flagMap = objectiveFlagValue

				if (flagMap == GetMapName())
					passFlags = true
			break

			case "SERVER_HOLIDAY" :
				dPrint(6, "Objective Flag Type matches " + objectiveFlagType)

				local flagHoliday = objectiveFlagValue

				if (IsHolidayActive(flagHoliday))
					passFlags = true
			break
		}

		if (passFlags)
			passAmt++

		dPrint(6, "PASS FLAG (" + objectiveFlagType +")? (" + passFlags + ") AMT (" + passAmt + ")")
	}

	if (passAmt == objectiveFlags.len())
		return true
	else
		return false
}
