//Few global vars to track the infections
GLOBAL_LIST_EMPTY(infections) //complete list of all infections made.
GLOBAL_LIST_EMPTY(infection_nodes)
GLOBAL_VAR(infection_core)
GLOBAL_VAR(infection_commander)

/mob/camera/commander
	name = "Infection Commander"
	real_name = "Infection Commander"
	desc = "The commander. It controls the infection."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = TRUE
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	color = "#00a7ff"

	pass_flags = PASSBLOB
	faction = list(ROLE_INFECTION)
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	hud_type = /datum/hud/infection_commander
	var/obj/structure/infection/core/infection_core = null // The infection commanders's core
	var/obj/effect/meteor/infection/meteor = null // The infection's incoming meteor
	var/infection_points = 0
	var/max_infection_points = 300
	var/upgrade_points = 0 // obtained by destroying beacons
	var/all_upgrade_points = 0 // all upgrade points earned so far
	var/last_attack = 0
	var/list/infection_mobs = list()
	var/list/resource_infection = list()
	var/nodes_required = 1 //if the infection needs nodes to place resource and factory blobs
	var/placed = FALSE
	var/base_point_rate = 2 //for core placement
	var/autoplace_time = 200 // a few seconds, just so it isnt sudden at game start
	var/place_beacons_delay = 100
	var/victory_in_progress = FALSE
	var/infection_color = "#ffffff"
	var/list/default_actions = list(/datum/action/innate/infection/creator/shield,
									/datum/action/innate/infection/creator/resource,
									/datum/action/innate/infection/creator/node,
									/datum/action/innate/infection/creator/factory)
	var/list/unlockable_actions = list(/datum/action/innate/infection/creator/turret)

/mob/camera/commander/Initialize(mapload, starting_points = 0)
	if(GLOB.infection_commander)
		return INITIALIZE_HINT_QDEL // there can be only one
	GLOB.infection_commander = src
	infection_points = starting_points
	autoplace_time += world.time
	last_attack = world.time
	if(infection_core)
		infection_core.update_icon()
	SSshuttle.registerHostileEnvironment(src)
	addtimer(CALLBACK(src, .proc/generate_announcement), place_beacons_delay / 2)
	addtimer(CALLBACK(src, .proc/place_beacons), place_beacons_delay)
	for(var/type_action in default_actions)
		var/datum/action/innate/infection/add_action = new type_action()
		add_action.Grant(src)
	.= ..()
	START_PROCESSING(SSobj, src)

/mob/camera/commander/proc/generate_announcement()
	priority_announce("Unfortunate news. An infectious core is headed to your station on a meteor.\n\n\
					   Infectious cores are almost indestructible beings that consume everything around them in order to replicate themselves. They adapt to almost any environment.\n\n\
					   Our calculations estimate the infection core will arrive in [(autoplace_time - world.time)/600] minutes.\n\n\
					   Forcefield Generators are being deployed to defend your station. Protect these from the bulk of the infection.",
					  "Biohazard Containment Commander", 'sound/misc/notice1.ogg')
	set_security_level(SEC_LEVEL_RED)

/mob/camera/commander/proc/defeated_announcement()
	priority_announce("You've defeated the infection, congratulations.",
					  "Biohazard Containment Commander", 'sound/misc/notice2.ogg')
	set_security_level(SEC_LEVEL_RED)

/mob/camera/commander/proc/place_beacons()
	for(var/obj/effect/landmark/beacon_start/B in GLOB.beacon_spawns)
		var/turf/T = get_turf(B)
		var/obj/structure/beacon_generator/G = new /obj/structure/beacon_generator(T.loc)
		G.forceMove(T)
		G.setDir(B.dir)
		INVOKE_ASYNC(G, /obj/structure/beacon_generator.proc/generateWalls)
		sleep(100 / GLOB.beacon_spawns.len)

/mob/camera/commander/process()
	if(!infection_core && !meteor)
		if(!placed)
			if(autoplace_time && world.time >= autoplace_time)
				place_infection_core()
		else
			qdel(src)
	else if(!victory_in_progress && !GLOB.infection_beacons.len && !meteor)
		victory_in_progress = TRUE
		priority_announce("It's over, the infection is unstoppable now.", "Biohazard Containment Commander")
		set_security_level("delta")
		max_infection_points = INFINITY
		infection_points = INFINITY
		addtimer(CALLBACK(src, .proc/victory), 250)
	..()


/mob/camera/commander/proc/victory()
	sound_to_playing_players('sound/machines/alarm.ogg')
	sleep(100)
	for(var/i in GLOB.mob_living_list - src)
		var/mob/living/L = i
		var/turf/T = get_turf(L)
		if(!T || !is_station_level(T.z))
			continue

		if(L in GLOB.overminds || (L.pass_flags & PASSBLOB))
			continue

		var/area/Ablob = get_area(T)

		if(!Ablob.blob_allowed)
			continue

		if(!(ROLE_INFECTION in L.faction))
			playsound(L, 'sound/effects/splat.ogg', 50, 1)
			L.death()
			new/mob/living/simple_animal/hostile/infection/infectionspore(T)
		else
			L.fully_heal()

		for(var/area/A in GLOB.sortedAreas)
			if(!(A.type in GLOB.the_station_areas))
				continue
			if(!A.blob_allowed)
				continue
			A.color = infection_color
			A.name = "infection"
			A.icon = 'icons/mob/blob.dmi'
			A.icon_state = "blob_shield"
			A.layer = BELOW_MOB_LAYER
			A.invisibility = 0
			A.blend_mode = 0
	var/datum/antagonist/infection/I = mind.has_antag_datum(/datum/antagonist/infection)
	if(I)
		var/datum/objective/infection_takeover/main_objective = locate() in I.objectives
		if(main_objective)
			main_objective.completed = TRUE
	to_chat(world, "<B>[real_name] consumed the station in an unstoppable tide!</B>")
	SSticker.news_report = BLOB_WIN
	SSticker.force_ending = TRUE

/mob/camera/commander/Destroy()
	GLOB.infection_commander = null
	for(var/IN in GLOB.infections)
		var/obj/structure/infection/I = IN
		if(I && I.overmind == src)
			I.overmind = null
			I.update_icon() //reset anything that was ours
	for(var/IB in infection_mobs)
		var/mob/living/simple_animal/hostile/infection/I = IB
		if(I)
			I.overmind = null
			I.update_icons()
	STOP_PROCESSING(SSobj, src)

	SSshuttle.clearHostileEnvironment(src)

	addtimer(CALLBACK(src, .proc/defeated_announcement), 80)

	return ..()

/mob/camera/commander/Login()
	..()
	to_chat(src, "<span class='notice'>You are the infection!</span>")
	infection_help()
	update_health_hud()
	add_points(0)

/mob/camera/commander/examine(mob/user)
	..()
	to_chat(user, "<font color=[infection_color]>The commander of the infection.</font>")

/mob/camera/commander/update_health_hud()
	if(infection_core)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(infection_core.obj_integrity)]</font></div>"

/mob/camera/commander/proc/add_points(points)
	infection_points = clamp(infection_points + points, 0, max_infection_points)
	hud_used.infectionpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(infection_points)]</font></div>"

/mob/camera/commander/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	infection_talk(message)

/mob/camera/commander/proc/infection_talk(message)

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	src.log_talk(message, LOG_SAY)

	var/message_a = say_quote(message, get_spans())
	var/rendered = "<span class='big'><font color=\"#EE4000\"><b>(<font color=\"[infection_color]\">[src.name]</font>)</b> [message_a]</font></span>"

	for(var/mob/M in GLOB.mob_list)
		if(iscommander(M) || isinfectionmonster(M))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/mob/camera/commander/blob_act(obj/structure/infection/I)
	return

/mob/camera/commander/Stat()
	..()
	if(statpanel("Status"))
		if(infection_core)
			stat(null, "Core Health: [infection_core.obj_integrity]")
			stat(null, "Power Stored: [infection_points]/[max_infection_points]")
			stat(null, "Upgrade Points: [upgrade_points]")
			stat(null, "Beacons Remaining: [GLOB.infection_beacons.len]")
		if(!placed)
			stat(null, "Time Before Automatic Placement: [max(round((autoplace_time - world.time)*0.1, 0.1), 0)]")

/mob/camera/commander/Move(NewLoc, Dir = 0)
	if(meteor)
		return FALSE
	forceMove(NewLoc)
	return TRUE
