/turf/open/floor/plating/dirt
	gender = PLURAL
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon = 'icons/turf/floors.dmi'
	icon_state = "dirt"
	base_icon_state = "dirt"
	baseturfs = /turf/open/chasm/jungle
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	planetary_atmos = TRUE
	attachment_holes = FALSE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/plating/dirt/setup_broken_states()
	return list("dirt")

/turf/open/floor/plating/dirt/dark
	icon_state = "greenerdirt"
	base_icon_state = "greenerdirt"

/turf/open/floor/plating/dirt/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/dirt/jungle
	slowdown = 0.5
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/floor/plating/dirt/jungle/dark
	icon_state = "greenerdirt"
	base_icon_state = "greenerdirt"

/turf/open/floor/plating/dirt/jungle/wasteland //Like a more fun version of living in Arizona.
	name = "cracked earth"
	desc = "Looks a bit dry."
	icon = 'icons/turf/floors.dmi'
	icon_state = "wasteland"
	base_icon_state = "wasteland"
	slowdown = 1
	var/floor_variance = 15

/turf/open/floor/plating/dirt/jungle/wasteland/setup_broken_states()
	return list("[initial(icon_state)]0")

/turf/open/floor/plating/dirt/jungle/wasteland/Initialize()
	.=..()
	if(prob(floor_variance))
		icon_state = "[initial(icon_state)][rand(0,12)]"

/turf/open/floor/plating/grass/jungle
	name = "jungle grass"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/floor/plating/dirt
	desc = "Greener on the other side."
	icon_state = "junglegrass"
	base_icon_state = "junglegrass"
	smooth_icon = 'icons/turf/floors/junglegrass.dmi'

/turf/open/floor/plating/grass/jungle/setup_broken_states()
	return list("junglegrass")

/turf/closed/mineral/random/jungle
	mineralSpawnChanceList = list(/obj/item/stack/ore/uranium = 10, /obj/item/stack/ore/diamond = 2, /obj/item/stack/ore/gold = 20,
		/obj/item/stack/ore/silver = 14, /obj/item/stack/ore/plasma = 40, /obj/item/stack/ore/iron = 80, /obj/item/stack/ore/titanium = 22,
		/obj/item/stack/ore/bluespace_crystal = 2, /turf/closed/mineral/strange_rock/volcanic = 10)
	turf_type = /turf/open/floor/plating/dirt/dark
	baseturfs = /turf/open/floor/plating/dirt/dark
