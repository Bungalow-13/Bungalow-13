/datum/job/commander
	title = "Commander"
	department_head = list("Solgov Command")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "space law"
	selection_color = "#89c7b1"
	maptype = "solgov"

	outfit = /datum/outfit/job/solgov

	access = list(ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CAPTAIN,  ACCESS_SECURITY, ACCESS_RND, ACCESS_ARMORY, ACCESS_HEADS, ACCESS_ATMOSPHERICS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CAPTAIN,  ACCESS_SECURITY, ACCESS_RND, ACCESS_ARMORY, ACCESS_HEADS, ACCESS_ATMOSPHERICS)
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_ENG

	liver_traits = list(TRAIT_ENGINEER_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CAPTAIN
	bounty_types = CIV_JOB_ENG

/datum/outfit/job/solgov
	name = "Solgov Survivor"
	id = /obj/item/card/id/solgov
	belt = null

