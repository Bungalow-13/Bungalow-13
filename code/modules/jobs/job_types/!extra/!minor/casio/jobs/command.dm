/datum/job/blueshield
	title = "Blueshield"
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the command staff"
	selection_color = "#bbbbee"
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_COMMAND
	maptype = list("naval")
	trusted_only = TRUE

	outfit = /datum/outfit/job/blueshield


	access = list(ACCESS_SECURITY, ACCESS_BLUESHIELD, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_WEAPONS, ACCESS_MECH_SECURITY,
					ACCESS_MORGUE, ACCESS_MAINT_TUNNELS,ACCESS_AUX_BASE, ACCESS_CARGO,
					ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING, ACCESS_EVA, ACCESS_TELEPORTER,
					ACCESS_HEADS, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_SECURITY, ACCESS_BLUESHIELD, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_WEAPONS, ACCESS_MECH_SECURITY,
					ACCESS_MORGUE, ACCESS_MAINT_TUNNELS,ACCESS_AUX_BASE, ACCESS_CARGO,
					ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING, ACCESS_EVA, ACCESS_TELEPORTER,
					ACCESS_HEADS, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)
	display_order = JOB_DISPLAY_ORDER_HIGH_COMMAND

//Captain code is in the goonlite folder
/datum/job/captain_green/naval
	maptype = list("naval")
	outfit = /datum/outfit/job/captain/nt
