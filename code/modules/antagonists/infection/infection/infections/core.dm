/obj/structure/infection/core
	name = "infection core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A huge, pulsating infectious mass. It almost seems to beckon you."
	max_integrity = 400
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 75, "acid" = 90)
	explosion_block = 6
	point_return = -1
	health_regen = 0 //we regen in Life() instead of when pulsed
	var/core_regen = 2
	var/resource_delay = 0
	var/point_rate = 2
	var/list/topulse = list()

/obj/structure/infection/core/Initialize(mapload, client/new_overmind = null, new_rate = 2, placed = 0)
	GLOB.infection_core = src
	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src
	update_icon() //so it atleast appears
	if(!placed && !overmind)
		return INITIALIZE_HINT_QDEL
	if(overmind)
		update_icon()
	point_rate = new_rate
	addtimer(CALLBACK(src, .proc/generate_announcement), 40)
	SSevents.frequency_lower = DOOM_CLOCK_EVENT_DELAY
	SSevents.frequency_upper = DOOM_CLOCK_EVENT_DELAY
	SSevents.reschedule()
	. = ..()

/obj/structure/infection/core/proc/generate_announcement()
	priority_announce("The infection core has landed, I hope you've prepared well.\n\n\
					   You should see our reinforcements warp in near the emergency shuttle outpost as we send them in.\n\n\
					   Good luck. I'll be here to notify you should anything change for better or for worse.",
					  "Biohazard Containment Commander", 'sound/misc/notice1.ogg')
	set_security_level(SEC_LEVEL_GAMMA)

/obj/structure/infection/core/show_infection_menu(var/mob/camera/commander/C)
	return

/obj/structure/infection/core/update_icon()
	cut_overlays()
	color = null
	var/mutable_appearance/infection_overlay = mutable_appearance('icons/mob/blob.dmi', "blob")
	if(overmind)
		infection_overlay.color = overmind.infection_color
	add_overlay(infection_overlay)
	add_overlay(mutable_appearance('icons/mob/blob.dmi', "blob_core_overlay"))

/obj/structure/infection/core/Destroy()
	. = ..()
	deathExplosion()
	GLOB.infection_core = null
	if(overmind)
		overmind.infection_core = null
	overmind = null
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list -= src

/obj/structure/infection/core/proc/deathExplosion()
	var/explodeloc = src.loc
	for(var/i = 1 to 9)
		for(var/atom/A in urange(i, explodeloc) - urange(i - 1, explodeloc))
			var/power = CEILING(i/3, 1)
			A.ex_act(power)
			if(istype(A, /obj/structure/infection))
				var/obj/structure/infection/INF = A
				INF.take_damage(600 / power, BRUTE, "bomb", 0)
		sleep(4)

/obj/structure/infection/core/ex_act(severity, target)
	return

/obj/structure/infection/core/bullet_act(obj/item/projectile/P)
	var/obj/effect/temp_visual/at_shield/AT = new /obj/effect/temp_visual/at_shield(loc, src)
	var/random_x = rand(-32, 32)
	AT.pixel_x += random_x

	var/random_y = rand(-32, 32)
	AT.pixel_y += random_y
	playsound(src.loc, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, 1, 10, pressure_affected = FALSE)
	src.visible_message("<span class='notice'>[P] plinks off of [src]!</span>")

/obj/structure/infection/core/attacked_by(obj/item/I, mob/living/user)
	if(!istype(I, /obj/item/infectionkiller))
		var/obj/effect/temp_visual/at_shield/AT = new /obj/effect/temp_visual/at_shield(loc, src)
		var/random_x = rand(-32, 32)
		AT.pixel_x += random_x

		var/random_y = rand(-32, 32)
		AT.pixel_y += random_y
		playsound(src.loc, 'sound/effects/bang.ogg', 100, 1, 10, pressure_affected = FALSE)
		user.visible_message("[user]'s [I] plinks off of [src]!", "<span class='notice'>[user]'s [I] plinks off of [src]!</span>")
		return
	if(I.force)
		visible_message("<span class='danger'>[src] bellows as [user] hits it with [I]!</span>", null, null, COMBAT_MESSAGE_RANGE)
		//only witnesses close by and the victim see a hit message.
		log_combat(user, src, "attacked", I)
	take_damage(I.force*5, I.damtype, "melee", 1, override = "infection_core")

/obj/structure/infection/core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, var/override = "")
	if(override != "infection_core")
		return
	. = ..()
	if(obj_integrity > 0)
		if(overmind) //we should have an overmind, but...
			overmind.update_health_hud()

/obj/structure/infection/core/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	for(var/mob/M in range(10,src))
		if(M.client)
			flash_color(M.client, "#FB6B00", 1)
			shake_camera(M, 4, 3)
	playsound(src.loc, pick('sound/effects/curseattack.ogg', 'sound/effects/curse1.ogg', 'sound/effects/curse2.ogg', 'sound/effects/curse3.ogg', 'sound/effects/curse4.ogg',), 300, 1, pressure_affected = FALSE)

/obj/structure/infection/core/Life()
	if(QDELETED(src))
		return
	if(!overmind)
		qdel(src)
	else
		if(resource_delay <= world.time)
			resource_delay = world.time + 10 // 1 second
			overmind.add_points(point_rate)
	obj_integrity = min(max_integrity, obj_integrity+core_regen)
	if(overmind)
		overmind.update_health_hud()
		Pulse_Area(overmind, 20, 40)
	for(var/obj/structure/infection/normal/I in range(1, src) + (range(6, src) - range(5, src)))
		INVOKE_ASYNC(I, .proc/change_to, /obj/structure/infection/shield/reflective/strong/core, overmind)
	var/list/turrets = list()
	turrets += locate(x-5,y+5,z)
	turrets += locate(x+5,y+5,z)
	turrets += locate(x-5,y-5,z)
	turrets += locate(x+5,y-5,z)
	for(var/turf/T in turrets)
		var/obj/structure/infection/normal/I = locate(/obj/structure/infection/normal) in T.contents
		if(I && prob(15))
			INVOKE_ASYNC(I, .proc/change_to, /obj/structure/infection/turret/core, overmind)
	INVOKE_ASYNC(src, .proc/pulseNodes)
	playsound(src.loc, 'sound/effects/singlebeat.ogg', 600, 1, pressure_affected = FALSE)
	..()

/obj/structure/infection/core/proc/pulseNodes()
	if(topulse.len)
		var/sleeptime = SSmobs.wait / topulse.len // constant expansion till the next life tick
		for(var/i = 1 to topulse.len)
			if(!topulse.len)
				return
			var/obj/structure/infection/node/N = pick(topulse)
			N.Pulse_Area(overmind)
			topulse -= N
			sleep(sleeptime)

/obj/structure/infection/core/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/stationloving, FALSE, TRUE)

/obj/structure/infection/core/onTransitZ(old_z, new_z)
	if(overmind && is_station_level(new_z))
		overmind.forceMove(get_turf(src))
	return ..()
