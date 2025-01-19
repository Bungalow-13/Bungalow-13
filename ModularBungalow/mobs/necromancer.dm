/mob/living/simple_animal/hostile/megafauna/necromancer
	name = "necromancer"
	desc = "A powerful mage in a dark armor. Legends say that he has sold his and countless souls of other mages for this power."
	health = 3600
	maxHealth = 3600
	armour_penetration = 20 // Low AP
	melee_damage_lower = 55 // HIGH damage
	melee_damage_upper = 55 // So yeah, it's a killer of weak people
	icon_state = "necromancer"
	icon_living = "necromancer"
	icon = 'ModularTegustation/Teguicons/megafauna.dmi'
	faction = list("necromancer")
	attack_sound = 'sound/weapons/punch1.ogg'
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	light_color = "#0F0F0F"
	light_range = 6
	light_power = 10
	movement_type = GROUND
	mouse_opacity = MOUSE_OPACITY_ICON
	speak_emote = list("says")
	speed = 3
	move_to_delay = 3
	vision_range = 10
	aggro_vision_range = 60 // Nowhere to run
	ranged = TRUE
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0.5, CLONE = 0.5, STAMINA = 0, OXY = 0.5)
	loot = list(/obj/item/clothing/suit/wizrobe/necromancer,
				/obj/item/clothing/head/wizard/magus/necromancer
				)
	crusher_loot = list(/obj/item/clothing/suit/wizrobe/necromancer,
						/obj/item/clothing/head/wizard/magus/necromancer,
						/obj/item/necromancer_sword
						)
	wander = FALSE
	del_on_death = TRUE
	blood_volume = BLOOD_VOLUME_NORMAL
	achievement_type = /datum/award/achievement/boss/necromancer_kill
	crusher_achievement_type = /datum/award/achievement/boss/necromancer_crusher
	score_achievement_type = /datum/award/score/necromancer_score
	deathmessage = "falls to the ground, decaying into glowing particles."
	deathsound = "sound/magic/curse.ogg"
	attack_action_types = list(/datum/action/innate/megafauna_attack/necrotic_revival,
							/datum/action/innate/megafauna_attack/lightning_strike,
							/datum/action/innate/megafauna_attack/repulse,
							)
	var/stage_two_actions = list(/datum/action/innate/megafauna_attack/nflight,
							/datum/action/innate/megafauna_attack/instant_strike,
							)
	var/stage_three_actions = list(/datum/action/innate/megafauna_attack/massacre,
							/datum/action/innate/megafauna_attack/blade_dash,
							/datum/action/innate/megafauna_attack/lightning_storm,
							)
	move_force = MOVE_FORCE_NORMAL

	var/flying = FALSE
	var/can_move = TRUE
	var/can_attack = TRUE
	var/current_stage = 1

	var/has_sword = FALSE
	var/obj/item/necromancer_sword/mob/sword

	var/revival_cooldown
	var/revival_cooldown_time = 10 SECONDS
	var/max_revived = 4 // Can't revive more than this number of remains per spell
	var/list/skeleton_types = list(/mob/living/simple_animal/hostile/skeleton/necromancer)
	var/strike_cooldown
	var/strike_cooldown_time = 6 SECONDS
	var/strike_range = 4
	var/strike_delay = 1
	var/repulse_cooldown
	var/repulse_cooldown_time = 6 SECONDS
	var/repulse_range = 3
	// Stage two spells
	var/flight_cooldown
	var/flight_cooldown_time = 14 SECONDS
	var/instant_strike_cooldown
	var/instant_strike_cooldown_time = 6 SECONDS
	// Stage three spells
	var/list/penta_angles = list(196, 48, 270, 128, 338)
	var/list/penta_distances = list(6, 6, 6, 6, 6)
	var/massacre_cooldown
	var/massacre_cooldown_time = 9 SECONDS
	var/dash_cooldown
	var/dash_cooldown_time = 6 SECONDS
	var/storm_cooldown
	var/storm_cooldown_time = 10 SECONDS
	var/storm_amount = 200 // How many times the lightning strikes.

/obj/item/necromancer_sword/mob // OP pls nerf
	armour_penetration = 25
	force = 65
	block_chance = 0
	wound_bonus = -100
	bare_wound_bonus = -100

/mob/living/simple_animal/hostile/megafauna/necromancer/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item && !isturf(A) && has_sword)
		used_item = sword
	..()

/datum/action/innate/megafauna_attack/necrotic_revival
	name = "Necrotic Revival"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "skeleton"
	chosen_message = "<span class='colossus'>You will now force skeletons to rise once more.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/lightning_strike
	name = "Lightning Strike"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "lightning"
	chosen_message = "<span class='colossus'>You will now strike with a force of lightning all around your target.</span>"
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/repulse
	name = "Repulse"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "repulse"
	chosen_message = "<span class='colossus'>You will now throw all enemies away from you.</span>"
	chosen_attack_num = 3

// Stage two spells

/datum/action/innate/megafauna_attack/nflight
	name = "Flight"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "jaunt"
	chosen_message = "<span class='colossus'>You will now toggle flight.</span>"
	chosen_attack_num = 101

/datum/action/innate/megafauna_attack/instant_strike
	name = "Instant Strike"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "lightning1"
	chosen_message = "<span class='colossus'>You will now strike with fast lightning bolts around your target.</span>"
	chosen_attack_num = 102

/// Stage three spells
/datum/action/innate/megafauna_attack/massacre
	name = "Massacre"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "declaration"
	chosen_message = "<span class='colossus'>You will swiftly strike with your blade.</span>"
	chosen_attack_num = 201

/datum/action/innate/megafauna_attack/blade_dash
	name = "Blade Dash"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "icebeam"
	chosen_message = "<span class='colossus'>You will now dash towards your target.</span>"
	chosen_attack_num = 202

/datum/action/innate/megafauna_attack/lightning_storm
	name = "Lightning Storm"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "storm"
	chosen_message = "<span class='colossus'>You will now start a giant storm near your target.</span>"
	chosen_attack_num = 203

/mob/living/simple_animal/hostile/megafauna/necromancer/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && flying)
		return FALSE
	adjustHealthEffects()
	return ..()

/mob/living/simple_animal/hostile/megafauna/necromancer/bullet_act(obj/projectile/P)
	if(flying)
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/mob/living/simple_animal/hostile/megafauna/necromancer/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, visible_message_flags = NONE)
	if(flying)
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/necromancer/AttackingTarget()
	if(can_attack)
		if(has_sword)
			if(isliving(target))
				var/mob/living/L = target
				sword.melee_attack_chain(src, L)
				if(L.health <= HEALTH_THRESHOLD_DEAD || L.stat == DEAD)
					devour(L)
				return TRUE
		return ..()

/mob/living/simple_animal/hostile/megafauna/necromancer/Move()
	if(!can_move)
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/necromancer/OpenFire()
	if(client)
		switch(chosen_attack)
			if(1)
				necrotic_revival()
			if(2)
				lightning_strike(target)
			if(3)
				repulse(FALSE)
			if(101)
				toggle_flight()
			if(102)
				instant_strike(target)
			if(201)
				massacre()
			if(202)
				blade_dash(target)
			if(203)
				lightning_storm(target)
		return
	Goto(target, move_to_delay, minimum_distance)
	var/remains_in_range = 0
	var/t_distance = get_dist(src, target)
	var/turf/target_loc = get_step(target, pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST))
	for(var/obj/effect/decal/remains/R in view(4, src))
		remains_in_range += 1
	if((revival_cooldown <= world.time) && ((remains_in_range > 0) && prob(remains_in_range * 20)))
		necrotic_revival()
	else if((flight_cooldown <= world.time) && (current_stage >= 2) && prob(50))
		toggle_flight()
	else if((dash_cooldown <= world.time) && (current_stage >= 3) && (t_distance > 0) && (t_distance < 16) && prob(80))
		blade_dash(target_loc)
	else if((repulse_cooldown <= world.time) && (t_distance < repulse_range) && prob(60))
		repulse(FALSE)
	else if((instant_strike_cooldown <= world.time) && (current_stage >= 2) && (t_distance > 1) && (t_distance < 11) && prob(60))
		instant_strike(target_loc)
	else if((storm_cooldown <= world.time) && (current_stage >= 3) && prob(40))
		lightning_storm(target)
	else if((massacre_cooldown <= world.time) && (current_stage >= 3) && (t_distance < 4))
		massacre()
	else if((strike_cooldown <= world.time) && (t_distance > 1) && (t_distance < 10))
		lightning_strike(target_loc)

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/adjustHealthEffects()
	if(health <= maxHealth*0.6)
		if(current_stage < 3)
			if(current_stage < 2) // In case of extraordinarily high damage (admemes?)
				stage_two()
			stage_three()
	else if(health <= maxHealth*0.8)
		if(current_stage < 2)
			stage_two()

/mob/living/simple_animal/hostile/megafauna/necromancer/devour(mob/living/L)
	for(var/obj/item/W in L)
		if(!L.dropItemToGround(W))
			qdel(W)
	visible_message("<span class='danger'>[src] turns [L] to dust!</span>","<span class='userdanger'>You annihilate [L], restoring your health!</span>")
	adjustHealth(-L.maxHealth*0.5)
	L.dust() // More remains to make skeletons from

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/necrotic_revival()
	if(revival_cooldown > world.time)
		return
	revival_cooldown = world.time + revival_cooldown_time
	say("Rise my servants!")
	playsound(src, 'sound/magic/voidblink.ogg', 80, 1)
	var/revived = 0
	for(var/turf/open/T in view(5, src))
		if(revived > max_revived)
			return
		var/successful_revival = FALSE
		for(var/obj/effect/decal/remains/R in T)
			var/mob/living/skeleton_type = pick(skeleton_types)
			new skeleton_type(T)
			revived += 1
			qdel(R)
			successful_revival = TRUE
		if(successful_revival)
			new /obj/effect/temp_visual/cult/blood/out(T)

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/lightning_strike(target)
	if(strike_cooldown > world.time)
		return
	strike_cooldown = world.time + strike_cooldown_time
	say("Lini Azam!")
	playsound(src, 'sound/magic/lightningshock.ogg', 60, 1)
	var/list/target_turfs = list()
	if(current_stage >= 3)
		instant_strike(target, TRUE)
	for(var/turf/open/T in range(strike_range, target))
		if(prob(40))
			target_turfs += T
			new /obj/effect/temp_visual/cult/turf/floor(T)
			addtimer(CALLBACK(src, PROC_REF(lightning_bolt), T), 7)
			SLEEP_CHECK_DEATH(strike_delay)

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/lightning_bolt(turf/open/T)
	if(!T)
		return // No turf? Do nothing.
	var/turf/lightning_source = get_step(get_step(T, NORTH), NORTH)
	if(lightning_source)
		lightning_source.Beam(T, icon_state="lightning[rand(1,12)]", time = 3)
	playsound(T, 'sound/magic/lightningbolt.ogg', 30, TRUE)
	for(var/mob/living/L in T)
		if("necromancer" in L.faction)
			continue
		L.adjustFireLoss(30)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.electrocution_animation(4)

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/repulse(forced = FALSE)
	if(!forced && repulse_cooldown > world.time)
		return
	repulse_cooldown = world.time + repulse_cooldown_time
	say("Gittah Weigh!")
	playsound(src, 'sound/magic/repulse.ogg', 60, TRUE)
	var/list/targets = list()
	for(var/turf/T in range(repulse_range, src))
		targets += T

	// Copy-paste from spell_types/wizard.dm
	var/list/thrownatoms = list()
	var/atom/throwtarget
	var/distfromcaster
	for(var/turf/T in targets)
		for(var/atom/movable/AM in T)
			thrownatoms += AM

	for(var/am in thrownatoms)
		var/atom/movable/AM = am
		if(AM == src || AM.anchored)
			continue

		throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(AM, src)))
		distfromcaster = get_dist(src, AM)
		if(distfromcaster == 0)
			if(isliving(AM))
				var/mob/living/M = AM
				if(!("necromancer" in M.faction))
					M.Paralyze(10)
					M.adjustBruteLoss(25)
					to_chat(M, "<span class='userdanger'>You're slammed into the floor by [src]!</span>")
		else
			new /obj/effect/temp_visual/gravpush(get_turf(AM), get_dir(src, AM))
			if(isliving(AM))
				var/mob/living/M = AM
				if(!("necromancer" in M.faction))
					M.adjustBruteLoss(5)
					to_chat(M, "<span class='userdanger'>You're thrown back by [src]!</span>")
			AM.safe_throw_at(throwtarget, ((clamp((5 - (clamp(distfromcaster - 2, 0, distfromcaster))), 3, 5))), 1,src, force = MOVE_FORCE_VERY_STRONG)


/* Stage two stuff */

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/stage_two()
	if(current_stage >= 2)
		return
	damage_coeff = list(BRUTE = 0.85, BURN = 0.4, TOX = 0.4, CLONE = 0.4, STAMINA = 0, OXY = 0.4)
	current_stage = 2
	max_revived = 5
	repulse_range = 4
	strike_range = 5
	icon_state = "necromancer_winged[has_sword]"
	icon_living = "necromancer_winged[has_sword]"
	icon = 'ModularTegustation/Teguicons/megafauna.dmi'
	update_icon()
	visible_message("<span class='boldannounce'>The [src] shivers for a moment as a pair of skeletal wings grow from his back!</span>")
	playsound(src, 'sound/effects/wounds/crack2.ogg', 100, 1)
	for(var/action_type in stage_two_actions)
		var/datum/action/innate/megafauna_attack/attack_action = new action_type()
		attack_action.Grant(src)
	skeleton_types = list(/mob/living/simple_animal/hostile/skeleton/necromancer/strong)

/datum/movespeed_modifier/necromancer_flight
	multiplicative_slowdown = -1.5

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/toggle_flight()
	if(!can_attack || (flight_cooldown > world.time))
		return
	flight_cooldown = world.time + 600 SECONDS // Actual cooldown is set on landing
	visible_message("<span class='boldwarning'>[src] takes off from the ground!</span>")
	flying = TRUE
	can_attack = FALSE
	repulse_cooldown = world.time + 600 SECONDS // So no double repulse
	ADD_TRAIT(src, TRAIT_MOVE_PHASING, "ability")
	add_movespeed_modifier(/datum/movespeed_modifier/necromancer_flight, update = TRUE)
	move_to_delay -= 1
	speed -= 1
	handle_automated_action()
	density = FALSE
	icon = 'ModularTegustation/Teguicons/96x32.dmi'
	icon_state = "necromancer_winged[has_sword]"
	icon_living = "necromancer_winged[has_sword]"
	pixel_x = -32
	update_icon()

	var/oldtransform = transform
	alpha = 255
	animate(src, alpha = 100, transform = matrix()*0.9, time = 5, easing = BOUNCE_EASING)
	animate(src, pixel_z = 16, time = 5, easing = BOUNCE_EASING)
	addtimer(CALLBACK(src, PROC_REF(stop_flight), oldtransform), 50)

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/stop_flight(oldtransform)
	can_move = FALSE
	if(target)
		forceMove(get_step(src, get_dir(src, target)))
	animate(src, alpha = 255, transform = oldtransform, 4)
	animate(pixel_z = 0, time = 4)
	SLEEP_CHECK_DEATH(4)
	flight_cooldown = world.time + flight_cooldown_time
	REMOVE_TRAIT(src, TRAIT_MOVE_PHASING, "ability")
	can_move = TRUE
	can_attack = TRUE
	density = TRUE
	flying = FALSE
	remove_movespeed_modifier(/datum/movespeed_modifier/necromancer_flight, update = TRUE)
	move_to_delay += 1
	speed += 1
	handle_automated_action()
	icon = 'ModularTegustation/Teguicons/megafauna.dmi'
	pixel_x = 0
	update_icon()
	playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	repulse(TRUE)

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/instant_strike(target, forced = FALSE)
	if(!forced && instant_strike_cooldown > world.time)
		return
	if(!forced)
		instant_strike_cooldown = world.time + instant_strike_cooldown_time
		say("Insati Li Azamo!")
	playsound(src, 'sound/magic/lightningshock.ogg', 60, 1)
	var/list/target_turfs = list()
	for(var/turf/open/T in range(2, target))
		if(prob(50))
			target_turfs += T
			new /obj/effect/temp_visual/cult/turf/floor(T)
			addtimer(CALLBACK(src, PROC_REF(lightning_bolt), T), 7)

/* Stage three stuff */

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/stage_three()
	if(current_stage >= 3)
		return
	damage_coeff = list(BRUTE = 0.7, BURN = 0.2, TOX = 0.2, CLONE = 0.2, STAMINA = 0, OXY = 0.2)
	current_stage = 3
	max_revived = 6
	repulse_range = 5
	strike_range = 6
	visible_message("<span class='boldannounce'>The [src] raises arm in the air as a sword materializes in his hand!</span>")
	playsound(src, 'sound/magic/wand_teleport.ogg', 100, 1)
	sword = new(src)
	has_sword = TRUE
	icon_state = "necromancer_winged[has_sword]"
	icon_living = "necromancer_winged[has_sword]"
	update_icon()
	melee_damage_lower = 0 // All the new damage is in the sword
	melee_damage_upper = 0
	skeleton_types |= /mob/living/simple_animal/hostile/skeleton/necromancer/mage
	for(var/action_type in stage_three_actions)
		var/datum/action/innate/megafauna_attack/attack_action = new action_type()
		attack_action.Grant(src)

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/massacre() // Uber pentagram-shaped attack
	if(massacre_cooldown > world.time)
		return
	massacre_cooldown = world.time + massacre_cooldown_time
	say("Ha-Nase Irel!")
	can_move = FALSE
	var/turf/beginning_turf = get_turf(src)
	var/turf/T = beginning_turf
	for(var/i in 1 to 3)
		T = get_step(T, NORTH)
	forceMove(T)
	var/list/target_turfs = list()
	var/turf/last_turf = T
	for(var/x in 1 to 5)
		var/turf/new_turf
		new_turf = get_turf_in_angle(penta_angles[x], last_turf, penta_distances[x])
		target_turfs += new_turf
		last_turf = new_turf
	last_turf = get_turf(src)
	for(var/turf/end_turf in target_turfs)
		blink(last_turf, end_turf, 50, TRUE)
		if(target_turfs[5] != end_turf)
			SLEEP_CHECK_DEATH(2)
		last_turf = end_turf
	src.forceMove(beginning_turf)
	can_move = TRUE

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/blink(turf/start_t, turf/end_t, duration, damaging = TRUE)
	var/obj/spot1 = new /obj/effect/temp_visual/dir_setting/cult/phase(start_t, src.dir)
	src.forceMove(end_t)
	playsound(src, 'sound/magic/blink.ogg', 100, 1)
	var/obj/spot2 = new /obj/effect/temp_visual/dir_setting/cult/phase(end_t, src.dir)
	spot1.Beam(spot2, "blood_beam", time=duration)
	if(!damaging)
		return
	for(var/turf/B in getline(start_t, end_t))
		for(var/mob/living/victim in B)
			if(!("necromancer" in victim.faction) && victim != src)
				sword.melee_attack_chain(src, victim)

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/blade_dash(target)
	if(flying || (dash_cooldown > world.time))
		return
	dash_cooldown = world.time + dash_cooldown_time
	say("Sif D'ie!")
	var/turf/start_turf = get_turf(src)
	var/turf/end_turf = get_turf(target)
	blink(start_turf, end_turf, 30, FALSE)
	can_attack = FALSE // To avoid shenanigans with instant death
	SLEEP_CHECK_DEATH(6)
	can_attack = TRUE
	if(!client && prob(30))
		massacre()

/mob/living/simple_animal/hostile/megafauna/necromancer/proc/lightning_storm(target)
	if(storm_cooldown > world.time)
		return
	storm_cooldown = world.time + storm_cooldown_time
	say("Un' Lim' Azam!")
	playsound(src, 'sound/magic/lightningshock.ogg', 100, 1)
	var/list/target_turfs = list()
	for(var/turf/open/T in range(strike_range*3, target))
		target_turfs += T
	for(var/x in 1 to storm_amount)
		var/turf/open/TT = pick(target_turfs)
		new /obj/effect/temp_visual/cult/turf/floor(TT)
		addtimer(CALLBACK(src, PROC_REF(lightning_bolt), TT), 9)
		SLEEP_CHECK_DEATH(strike_delay)
