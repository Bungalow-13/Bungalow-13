
//Sif loot
//crusher trophy
/obj/item/crusher_trophy/dark_energy
	name = "dark energy"
	desc = "A black ball of energy that was formed when Sif miraculously imploded. Suitable as a trophy for a kinetic crusher."
	icon = 'ModularBungalow/mobs/megafauna/rockplanet/sif/icons/sif.dmi'
	icon_state = "sif_energy"
	denied_type = /obj/item/crusher_trophy/dark_energy
	bonus_value = 30

/obj/item/crusher_trophy/dark_energy/effect_desc()
	return "mark detonation to perform a bash dealing <b>[bonus_value]</b> damage"

/obj/item/crusher_trophy/dark_energy/on_mark_detonation(mob/living/target, mob/living/user)
	if(!target)
		return
	var/chargeturf = get_turf(target) //get target turf
	if(!chargeturf)
		return
	var/dir = get_dir(user, chargeturf)//get direction
	var/turf/T = get_ranged_target_turf(chargeturf,dir,2)//get range of the turf
	if(!T)
		return
	playsound(user, pick('ModularBungalow/mobs/megafauna/rockplanet/sif/sound/whoosh1.ogg', 'ModularBungalow/mobs/megafauna/rockplanet/sif/sound/whoosh2.ogg', 'ModularBungalow/mobs/megafauna/rockplanet/sif/sound/whoosh3.ogg'), 300, 1)
	new /obj/effect/temp_visual/decoy/fading(loc,user)
	//Start bashing
	walk(user,0)
	setDir(dir)
	var/movespeed = 0.7
	walk_to(user, T, movespeed)
	target.apply_damage(bonus_value, BRUTE) // Damage
	var/atom/prevLoc = target.loc
	user.loc = prevLoc
	walk(user, 0)
	//Stop bashing
	new /obj/effect/temp_visual/decoy/fading(loc,user)
	playsound(user, 'sound/effects/meteorimpact.ogg', 200, 1, 2, 1)

//sword
/obj/item/melee/sword_of_the_forsaken
	name = "Sword of the Forsaken"
	desc = "A glowing giant heavy blade that grows and slightly shrinks in size depending on the wielder's strength."
	icon = 'ModularBungalow/mobs/megafauna/rockplanet/sif/icons/sif.dmi'
	icon_state = "sword_of_the_forsaken"
	lefthand_file = 'ModularBungalow/mobs/megafauna/rockplanet/sif/icons/item_lefthand.dmi'
	righthand_file = 'ModularBungalow/mobs/megafauna/rockplanet/sif/icons/item_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 25
	throwforce = 10
	block_chance = 10
	armour_penetration = 80
	hitsound = 'ModularBungalow/mobs/megafauna/rockplanet/sif/sound/sif_slash.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts", "guts", "gores")
	attack_verb_simple = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut", "gutted", "gored")
	sharpness = SHARP_EDGED
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

//Enables the sword to butcher bodies
/obj/item/melee/sword_of_the_forsaken/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 50, 100, 10)

//Sword blocking attacks, really hard to block projectiles but still possible.
/obj/item/melee/sword_of_the_forsaken/hit_reaction(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 5
	return ..()

//necklace
/obj/item/clothing/neck/necklace/necklace_of_the_forsaken
	name = "Necklace of the Forsaken"
	desc = "A rose gold necklace with a small static ember that burns inside of the black gem stone, making it warm to the touch."
	icon = 'ModularBungalow/mobs/megafauna/rockplanet/sif/icons/sif.dmi'
	icon_state = "necklace_forsaken_active"
	worn_icon = 'ModularBungalow/mobs/megafauna/rockplanet/sif/icons/worn.dmi'
	actions_types = list(/datum/action/item_action/hands_free/necklace_of_the_forsaken)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/carbon/human/active_owner
	var/numUses = 1

/obj/item/clothing/neck/necklace/necklace_of_the_forsaken/item_action_slot_check(slot)
	return slot == ITEM_SLOT_NECK

/obj/item/clothing/neck/necklace/necklace_of_the_forsaken/dropped(mob/user)
	..()
	if(active_owner)
		remove_necklace()

//Apply a temp buff until the necklace is used
/obj/item/clothing/neck/necklace/necklace_of_the_forsaken/proc/temp_buff(mob/living/carbon/human/user)
	to_chat(user, "<span class='warning'>You feel as if you have a second chance at something, but you're not sure what.</span>")
	if(do_after(user, 40, target = user))
		to_chat(user, "<span class='notice'>The ember warms you...</span>")
		ADD_TRAIT(user, TRAIT_NOHARDCRIT, "necklace_of_the_forsaken")//less chance of being gibbed
		active_owner = user

//Revive the user and remove buffs
/obj/item/clothing/neck/necklace/necklace_of_the_forsaken/proc/second_chance()
	icon_state = "necklace_forsaken_active"
	if(!active_owner)
		return
	var/mob/living/carbon/human/H = active_owner
	active_owner = null
	to_chat(H, "<span class='userdanger'>You feel a scorching burn fill your body and limbs!</span>")
	H.revive(TRUE, FALSE)
	remove_necklace() //remove buffs

//Remove buffs
/obj/item/clothing/neck/necklace/necklace_of_the_forsaken/proc/remove_necklace()
	icon_state = "necklace_forsaken_active"
	if(!active_owner)
		return
	REMOVE_TRAIT(active_owner, TRAIT_NOHARDCRIT, "necklace_of_the_forsaken")
	active_owner = null //just in case

//Add action
/datum/action/item_action/hands_free/necklace_of_the_forsaken
	check_flags = NONE
	name = "Necklace of the Forsaken"
	desc = "Bind the necklaces ember to yourself, so that next time you activate it, it will revive or fully heal you whether dead or knocked out. (Beware of being gibbed)"

//What happens when the user clicks on datum
/datum/action/item_action/hands_free/necklace_of_the_forsaken/Trigger()
	var/obj/item/clothing/neck/necklace/necklace_of_the_forsaken/MM = target
	if(MM.numUses == 0)//skip if it has already been used up
		return
	if(!MM.active_owner)//apply bind if there is no active owner
		if(ishuman(owner))
			MM.temp_buff(owner)
		src.desc = "Revive or fully heal yourself, but you can only do this once! Can be used when knocked out or dead."
		to_chat(MM.active_owner, "<span class='userdanger'>You have binded the ember to yourself! The next time you use the necklace it will heal you!</span>")
	else if(MM.numUses == 1 && MM.active_owner)//revive / heal then remove usage
		MM.second_chance()
		MM.numUses = 0
		MM.icon_state = "necklace_forsaken"
		MM.desc = "A rose gold necklace that used to have a bright burning ember inside of it."
		src.desc = "The necklaces ember has already been used..."

//necropolis loot chest
/obj/structure/closet/crate/necropolis/sif
	name = "Great Brown Wolf Sif's chest"

/obj/structure/closet/crate/necropolis/sif/PopulateContents()
	new /obj/item/melee/sword_of_the_forsaken(src)
	new /obj/item/clothing/neck/necklace/necklace_of_the_forsaken(src)

/obj/structure/closet/crate/necropolis/sif/crusher
	name = "Great Brown Wolf Sif's infinity chest"

/obj/structure/closet/crate/necropolis/sif/crusher/PopulateContents()
	new /obj/item/melee/sword_of_the_forsaken(src)
	new /obj/item/clothing/neck/necklace/necklace_of_the_forsaken(src)
	new /obj/item/crusher_trophy/dark_energy(src)

//zweihander - it's just a one handed crusher
//I'll fix this later - Kirie
/obj/item/melee/zweihander
	icon = 'ModularBungalow/zbungalowicons/weapons/melee.dmi'
	icon_state = "zweihander"
	resistance_flags = FIRE_PROOF | UNACIDABLE | INDESTRUCTIBLE
	lefthand_file = 'ModularBungalow/zbungalowicons/weapons/melee_lefthand.dmi'
	righthand_file = 'ModularBungalow/zbungalowicons/weapons/melee_righthand.dmi'
	name = "Zweihander"
	desc = "A surprisingly tough sword, made out of drake hide and bone. Somehow, despite it's large size, it's easy to carry one handed."
	force = 15
	w_class = WEIGHT_CLASS_BULKY
	throwforce = 15
	throw_speed = 4
	armour_penetration = 20
	custom_materials = list(/datum/material/titanium=3150, /datum/material/glass=2075, /datum/material/gold=3000, /datum/material/diamond=5000)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_simple = list("smashed", "crushed", "cleaved", "chopped", "pulped")
	sharpness = SHARP_EDGED
	var/list/trophies = list()
	var/charged = TRUE
	var/charge_time = 12
	var/detonation_damage = 65
	var/backstab_bonus = 40
	var/brightness = 7

/obj/item/melee/zweihander/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 80, 110)
	set_light(brightness)

/obj/item/melee/zweihander/Destroy()
	QDEL_LIST(trophies)
	return ..()

/obj/item/melee/zweihander/examine(mob/living/user)
	. = ..()
	. += "<span class='notice'>Mark a large creature with the destabilizing force, then hit them in melee to do <b>[force + detonation_damage]</b> damage.</span>"
	. += "<span class='notice'>Does <b>[force + detonation_damage + backstab_bonus]</b> damage if the target is backstabbed, instead of <b>[force + detonation_damage]</b>.</span>"
	for(var/t in trophies)
		var/obj/item/crusher_trophy/T = t
		. += "<span class='notice'>It has \a [T] attached, which causes [T.effect_desc()].</span>"

/obj/item/melee/zweihander/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/crowbar))
		if(LAZYLEN(trophies))
			to_chat(user, "<span class='notice'>You remove [src]'s trophies.</span>")
			I.play_tool_sound(src)
			for(var/t in trophies)
				var/obj/item/crusher_trophy/T = t
				T.remove_from(src, user)
		else
			to_chat(user, "<span class='warning'>There are no trophies on [src].</span>")
	else if(istype(I, /obj/item/crusher_trophy))
		var/obj/item/crusher_trophy/T = I
		T.add_to(src, user)
	else
		return ..()

/obj/item/melee/zweihander/attack(mob/living/target, mob/living/carbon/user)
	var/datum/status_effect/crusher_damage/C = target.has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
	var/target_health = target.health
	..()
	for(var/t in trophies)
		if(!QDELETED(target))
			var/obj/item/crusher_trophy/T = t
			T.on_melee_hit(target, user)
	if(!QDELETED(C) && !QDELETED(target))
		C.total_damage += target_health - target.health //we did some damage, but let's not assume how much we did

/obj/item/melee/zweihander/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	. = ..()
	if(istype(target, /obj/item/crusher_trophy))
		var/obj/item/crusher_trophy/T = target
		T.add_to(src, user)
	if(!proximity_flag && charged)//Mark a target, or mine a tile.
		var/turf/proj_turf = user.loc
		if(!isturf(proj_turf))
			return
		var/obj/projectile/destabilizer/D = new /obj/projectile/destabilizer(proj_turf)
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_projectile_fire(D, user)
		D.preparePixelProjectile(target, user, clickparams)
		D.firer = user
		D.hammer_synced = src
		playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, 1)
		D.fire()
		charged = FALSE
		update_icon()
		addtimer(CALLBACK(src, PROC_REF(Recharge)), charge_time)
		return
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(STATUS_EFFECT_CRUSHERMARK)
		if(!CM || CM.hammer_synced != src || !L.remove_status_effect(STATUS_EFFECT_CRUSHERMARK))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		var/target_health = L.health
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, user)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health //we did some damage, but let's not assume how much we did
			new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(type = "bomb")
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				if(!QDELETED(C))
					C.total_damage += detonation_damage + backstab_bonus //cheat a little and add the total before killing it, so certain mobs don't have much lower chances of giving an item
				L.apply_damage(detonation_damage + backstab_bonus, BRUTE, blocked = def_check)
				playsound(user, 'sound/weapons/kenetic_accel.ogg', 100, 1) //Seriously who spelled it wrong
			else
				if(!QDELETED(C))
					C.total_damage += detonation_damage
				L.apply_damage(detonation_damage, BRUTE, blocked = def_check)


/obj/item/melee/zweihander/proc/Recharge()
	if(!charged)
		charged = TRUE
		update_icon()
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
