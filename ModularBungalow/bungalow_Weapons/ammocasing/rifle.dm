//BULLETS

// AK-47 bullet
/obj/item/ammo_casing/ballistic/a762_39
	name = "7.62x39mm bullet casing"
	desc = "A 7.62x39mm bullet casing."
	icon_state = "762x39-casing"
	caliber = "7.62x39mm"
	variance = 2
	projectile_type = /obj/projectile/bullet/a762_39

/obj/item/ammo_casing/ballistic/a545_39
	name = "5.45x39mm bullet casing"
	desc = "A 5.45x39mm bullet casing."
	icon_state = "762-casing"
	caliber = "5.45x39mm"
	randomspread = TRUE
	variance = 2
	projectile_type = /obj/projectile/bullet/a545_39

/obj/projectile/bullet/a762_39
	name = "7.62x39mm bullet"
	damage = 27

/obj/projectile/bullet/a545_39
	name = "5.45x39mm bullet"
	damage = 34

// t-12 bullet
/obj/item/ammo_casing/ballistic/a10_24
	name = "10x24mm bullet casing"
	desc = "A 10x24mm bullet casing."
	icon_state = "762-casing"
	caliber = "10x24mm"
	variance = 2
	projectile_type = /obj/projectile/bullet/a10_24

/obj/projectile/bullet/a10_24
	name = "10x24mm bullet"
	damage = 26
	armour_penetration = 25

// autogun bullet
/obj/item/ammo_casing/ballistic/a762_51
	name = "7.62x51mm bullet casing"
	desc = "A 7.62x51mm bullet casing."
	icon_state = "762x39-casing"
	caliber = "7.62x51"
	variance = 5
	projectile_type = /obj/projectile/bullet/a762_51

/obj/projectile/bullet/a762_51
	name = "7.62x51mm bullet"
	damage = 26


//CUSTOM KEPLER STUFF BELOW

/obj/item/ammo_box/magazine/m556/big
	name = "5.56 50 round box magazine"
	icon_state = "556big-50"
	icon = 'ModularBungalow/bungalow_Weapons/_icon/ammo_box.dmi'
	max_ammo = 50
/obj/item/ammo_box/magazine/m556/big/update_icon()
	..()
	if (ammo_count() == 0)
		icon_state = "556big-0"
	else
		icon_state = "556big-50"

/obj/item/ammo_casing/a556/pl
	projectile_type = /obj/projectile/bullet/a556/pl
/obj/projectile/bullet/a556/pl
	name = "5.56mm police load bullet"
	damage = 20
	stamina = 50
	armour_penetration = -30
	wound_bonus = -20
	armour_penetration = 60
	wound_bonus = -70
	ricochets_max = 5
	ricochet_chance = 140
	ricochet_auto_aim_angle = 50
	ricochet_auto_aim_range = 6
	ricochet_incidence_leeway = 80
	ricochet_decay_chance = 1

/obj/item/ammo_casing/a556/sk
	projectile_type = /obj/projectile/bullet/a556/sk
/obj/projectile/bullet/a556/sk
	name = "5.56mm silent killer bullet"
	damage = 13
	armour_penetration = 10
	wound_bonus = -70
	eyeblur = 20
	knockdown = 5
	slur = 50

/obj/projectile/bullet/a556/sk/on_hit(atom/target, blocked)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/targetHuman = target
		targetHuman.reagents.add_reagent(/datum/reagent/toxin, 10)
	else
		damage = 50

/obj/item/ammo_casing/a556/highp
	projectile_type = /obj/projectile/bullet/a556/highp
/obj/projectile/bullet/a556/highp
	name = "5.56mm high power bullet"
	damage = 45
	armour_penetration = 40
	wound_bonus = 20
	stamina = 30

/obj/item/ammo_casing/a50bwf
	name = ".50 beowulf bullet casing"
	desc = "A .50 beowulfe bullet casing."
	caliber = CALIBER_50
	projectile_type = /obj/projectile/bullet/a50bwf

/obj/projectile/bullet/a50bwf
	name =".50 beowulf bullet"
	speed = 0.4
	damage = 45
	paralyze = 10
	armour_penetration = 25
	var/breakthings = TRUE

/obj/projectile/bullet/a50bwf/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ismovable(target))
		var/atom/movable/M = target
		var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
		M.safe_throw_at(throw_target, 2, 1)
