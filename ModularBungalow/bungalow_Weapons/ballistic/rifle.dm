// AK-47
/obj/item/gun/ballistic/automatic/ak47
	name = "AK-47"
	desc = "An old assault rifle, dating back to 20th century. It is commonly used by various bandits, pirates and colonists due to its cheap production and maintenance cost."
	icon = 'ModularTegustation/Teguicons/48x32_guns.dmi'
	icon_state = "ak47"
	base_pixel_x = -8
	fire_sound = 'ModularTegustation/Tegusounds/weapons/guns/ak47.ogg'
	burst_size = 1
	actions_types = list()
	mag_display = TRUE
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_BULKY
	mag_type = /obj/item/ammo_box/magazine/ak47

/obj/item/gun/ballistic/automatic/ak47/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.15 SECONDS)

// AKS-74U
// Hits much harder than AK-47, but players can't obtain it normally.
/obj/item/gun/ballistic/automatic/aks74u
	name = "AKS-74U"
	desc = "A compact assault carbine with a foldable stock for easier transportation. Although old, it is still commonly used by some guerrilla fighters and other militias around the universe."
	icon = 'ModularTegustation/Teguicons/48x32_guns.dmi'
	icon_state = "aks74u"
	fire_sound = 'ModularTegustation/Tegusounds/weapons/guns/ak47.ogg' // Temporary
	burst_size = 1
	actions_types = list()
	mag_display = TRUE
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/aks74u

/obj/item/gun/ballistic/automatic/aks74u/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.12 SECONDS)

//T-12
/obj/item/gun/ballistic/automatic/t12
	name = "T-12"
	desc = "A heavily modified version of the Vrax that is being used as SolGov's main LMG."
	icon = 'ModularBungalow/bungalow_Weapons/_icon/48x32sprites.dmi'
	lefthand_file = 'ModularTegustation/Teguicons/teguitems_hold_left.dmi'
	righthand_file = 'ModularTegustation/Teguicons/teguitems_hold_right.dmi'
	icon_state = "t12"
	inhand_icon_state = "t12"
	fire_sound = "gun_t12"
	lock_back_sound = 'sound/weapons/gun/general/chunkyrack.ogg'
	bolt_drop_sound = 'sound/weapons/gun/pistol/slide_drop.ogg'
	base_pixel_x = -8
	burst_size = 1
	force = 14
	actions_types = list()
	mag_display = TRUE
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	bolt_type = BOLT_TYPE_LOCKING
	mag_type = /obj/item/ammo_box/magazine/t12

/obj/item/gun/ballistic/automatic/t12/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/ballistic/automatic/autogun
	name = "Vrax Battle Rifle"
	desc = "A standard battle rifle used by the SolGov military."
	icon = 'ModularBungalow/bungalow_Weapons/_icon/48x32sprites.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	icon_state = "autogun"
	inhand_icon_state = "l6m"
	fire_sound = "gun_t12"
	lock_back_sound = 'sound/weapons/gun/general/bolt_rack.ogg'
	bolt_drop_sound = 'sound/weapons/gun/pistol/slide_drop.ogg'
	base_pixel_x = -8
	burst_size = 1
	force = 12
	actions_types = list()
	mag_display = TRUE
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	bolt_type = BOLT_TYPE_LOCKING
	mag_type = /obj/item/ammo_box/magazine/autogun

/obj/item/gun/ballistic/automatic/autogun/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.3 SECONDS)

/obj/item/gun/ballistic/automatic/l6magfed
	name = "\improper L6-M HAR"
	desc = "A heavy 5.56 rifle, designated the 'L6-M HAR'. Has 'Scarborough Arms - Opportuna Forore.' stamped on the receiver. Has a threaded barrel for suppressors."
	icon = 'ModularBungalow/bungalow_Weapons/_icon/ballistics.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	icon_state = "l6m"
	inhand_icon_state = "l6m"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/m556
	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	can_suppress = TRUE
	suppressor_x_offset = 9
	spread = 4
	pin = /obj/item/firing_pin/implant/pindicate
	bolt_type = BOLT_TYPE_STANDARD
	show_bolt_icon = FALSE
	mag_display = TRUE
	tac_reloads = TRUE
	fire_sound = 'sound/weapons/gun/l6/shot.ogg'
	rack_sound = 'sound/weapons/gun/l6/l6_rack.ogg'
	suppressed_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'

/obj/item/gun/ballistic/automatic/l6magfed/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/l6magfed/Initialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

//Surplus Rifle .45 ACP
/obj/item/gun/ballistic/automatic/surplus/acp45
	desc = "A mostly obsolete cheap semi-auto rifle chambered in .45 ACP."
	fire_delay = 15
	icon = 'ModularBungalow/bungalow_Weapons/_icon/ballistics.dmi'
	icon_state = "surplus2"
	mag_type = /obj/item/ammo_box/magazine/surplusrifle/acp45
	bolt_type = BOLT_TYPE_LOCKING

/obj/item/gun/ballistic/automatic/laser/burst
	name = "L-807 Neo Laser Burst Rifle "
	desc = "The Miracle of the L-804, in it's full burst fire glory."
	icon_state = "laserburst"
	burst_size = 3




//OORAH SIR YES SIR!
/obj/item/gun/ballistic/automatic/m90/unrestricted/auto/halo
	name = "MA5C Individual Combat Weapons System"
	desc = "An air-cooled, gas-operated, magazine fed weapon designed for automatic fire."
	icon_state = "halo"
	inhand_icon_state = "hk21"
	icon = 'ModularBungalow/bungalow_Weapons/_icon/ballistics.dmi'
	fire_sound = 'sound/weapons/gun/l6/shot.ogg'
	rack_sound = 'sound/weapons/gun/l6/l6_rack.ogg'
	pin = /obj/item/firing_pin/explorer

/obj/item/gun/ballistic/automatic/m90/unrestricted/auto/halo/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.13 SECONDS)


//Kepler guns
//Sprite by kirie and akira!
/obj/item/gun/ballistic/automatic/m90/xm29
	name = "KT-XM29 'Determinator'"
	desc = "A grenade launcher with an assault rifle attached to it. Developed alongside the XM25, this weapon was a proposed alternative assault rifle for the specialised unit, however it was never distributed among the armed forces."
	icon_state = "xm29"
	inhand_icon_state = "xm"
	icon = 'ModularBungalow/bungalow_Weapons/_icon/ballistics.dmi'
	fire_sound = 'sound/weapons/gun/l6/shot.ogg'
	rack_sound = 'sound/weapons/gun/l6/l6_rack.ogg'
	pin = /obj/item/firing_pin
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	zoomable = TRUE
	zoom_amt = 8
	zoom_out_amt = 4
	fire_delay = 0.28

/obj/item/gun/ballistic/automatic/m90/xm29/Initialize()
	. = ..()
	underbarrel = new /obj/item/gun/ballistic/revolver/grenadelauncher/xm29(src)
	update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/xm29
	mag_type = /obj/item/ammo_box/magazine/internal/grenadelauncher/cylinder/xm29
	pin = /obj/item/firing_pin

/obj/item/ammo_box/magazine/internal/grenadelauncher/cylinder/xm29
	name = "grenade launcher internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = CALIBER_40MM
	max_ammo = 1

//being a rare weapon with decent firerate
/obj/item/gun/ballistic/automatic/gyropistol/xm25
	name = "KT-XM25 'Crow'"
	desc = "A gun developed by Kepler Technology. The XM25 is an experimental airburst grenade launcher designed to destroy barricades at long ranges and to weed out targets in cover. It was never officially adopted by Sol Government, but some functional prototypes were used during the occult war. This one has been kept in a good condition."
	icon_state = "xm25"
	inhand_icon_state = "xm"
	icon = 'ModularBungalow/bungalow_Weapons/_icon/ballistics.dmi'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	zoomable = TRUE
	zoom_amt = 8
	zoom_out_amt = 4

/obj/item/gun/ballistic/automatic/gyropistol/xm25/Initialize()
	. = ..()
	fire_delay = 14


/obj/item/gun/ballistic/automatic/ar/hk21
	name = "\improper SG-GPM21 'Terminator'"
	desc = "A general purpose standard issue battle rifle number 21, typically used by standard peacekeeping force for off-world colonies where advanced laser weaponry are not available. Some are of the gun are locally produced by Kepler Technology and fielded by rangers"
	icon = 'ModularBungalow/bungalow_Weapons/_icon/ballistics.dmi'
	icon_state = "hk21"
	inhand_icon_state = "hk21"
	slot_flags = 0
	burst_size = 1
	fire_sound = 'sound/weapons/gun/l6/shot.ogg'
	rack_sound = 'sound/weapons/gun/l6/l6_rack.ogg'
	weapon_weight = WEAPON_HEAVY

/obj/item/gun/ballistic/automatic/ar/hk21/Initialize()
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.16 SECONDS)

//DO NOT ADMIN ABUSE THIS IN, I WILL ACTUALLY GUT YOU.
/obj/item/gun/ballistic/automatic/ar/hk21/beowulf
	name = "\improper KT-XM38 .50 'Wulfe'"
	desc = "A modified FN-FAL made to chamber the .50 Beowulf Cartridges, although intended to be pushed into service by 2138 at the latest, It was never officially adopted by the Solgov Service. Nevertheless, it saw action during the first occult war"
	icon_state = "beowulf"
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds/beowulf

/obj/item/ammo_box/magazine/sniper_rounds/beowulf
	name = "beowulf magazine (.50)"
	max_ammo = 10
	caliber = CALIBER_50

/obj/item/gun/ballistic/automatic/ar/hk21/beowulf/Initialize()
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.24 SECONDS)

//THE MARSOC ARE COMING RUN
/obj/item/gun/ballistic/automatic/ar/hk21/marsoc
	name = "\improper KT-GPM21S 'Peacemaker'"
	desc = "A variant of the Sol Government Standard Issue Rifle Number 21 modified with a shortened stock and barrel for close quarter combat, developed during the occult war. <b>Foxtrot-1, finish the job!</b>"
	icon_state = "hk21c"
	inhand_icon_state = "hk21c"
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_LIGHT

/obj/item/gun/ballistic/automatic/ar/hk21/marsoc/Initialize()
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.11 SECONDS)

/obj/item/gun/ballistic/automatic/sniper_rifle/solgov
	name = "KT-LR45 'Divine Wind"
	desc = "A rare sniper rifle only issued in limited numbers to Kepler Ranger, although some has been given out as prizes for veteran of the occult war. It saw extremely limited service and only 200 of these rifle were ever produced, it still received an official military designation by the US Military but was never adopted by other countries in Sol. Well-liked for it's high accuracy even in the worst of condition, it's built in high-magnification scope makes it unmatched by most rifle of it's time, alongside it's extremely light weight nature. The rifle was deemed too expensive to replace the existing SR25 and was rejected in the finale."
	icon_state = "rifle45"
	inhand_icon_state = "rifle45"
	icon = 'ModularBungalow/bungalow_Weapons/_icon/48x32sprites.dmi'
	mag_display_ammo = 1
	spawnwithmagazine = 1
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds/solgov_longrifle
	projectile_damage_multiplier = 1.6

//Believe it or not this was actually the first gun I made when working on the server
/obj/item/gun/ballistic/automatic/sniper_rifle/solgov/ranger
	name = "Prototype Number 40 Long Rifle"
	desc = "A Sol Government Standard Issues Sniper Rifle Number 40, despite it's name it was actually fielded in 2100s and was one of the first Kepler Technoloy gun ever produced, although it failed to beat other guns in the competition, it was affordable and was utilised by the New Moscow Police Department."
	icon_state = "rifle40"
	inhand_icon_state = "rifle40"
	projectile_damage_multiplier = 1.4

//Used for both of these!
/obj/item/ammo_box/magazine/sniper_rounds/solgov_longrifle
	name = "long rifle magazine (7.12x82)"
	desc = "magazine for the long rifle"
	max_ammo = 12
	caliber = CALIBER_712X82MM
	ammo_type = /obj/item/ammo_casing/mm712x82

/obj/item/ammo_box/magazine/sniper_rounds/solgov_longrifle/ap
	name = "armor piercing long rifle magazine (7.12x82)"
	desc = "Powerful round capable of piercing armor"
	ammo_type = /obj/item/ammo_casing/mm712x82/ap

/obj/item/ammo_box/magazine/sniper_rounds/solgov_longrifle/hp
	name = "hollow point long rifle magazine (7.12x82)"
	desc = "Powerful round capable of shredding organic lifeform"
	ammo_type = /obj/item/ammo_casing/mm712x82/hollow

/obj/item/ammo_box/magazine/sniper_rounds/solgov_longrifle/incen
	name = "incendiary long rifle magazine (7.12x82)"
	desc = "Incendiary munition, Let em burn"
	ammo_type = /obj/item/ammo_casing/mm712x82/incen
/obj/item/gun/ballistic/automatic/sr25
	name = "SG-SR25 'Knight'"
	desc = "The SR25 is a rifle used by the early Sol Government's expedition force, chambered in the 7.62 NATO ammunition. It's well-liked by marksman who were given it, although early model had issues where the gun would occasionally jam up if fired too rapidly. This one has rectified that issues and remains in service. Additionally it has been often sighted in the hand of US MARSOC"
	icon_state = "sr25"
	inhand_icon_state = "hk21"
	icon = 'ModularBungalow/bungalow_Weapons/_icon/ballistics.dmi'
	mag_display_ammo = 1
	spawnwithmagazine = 0
	mag_type = /obj/item/ammo_box/magazine/sr25
	fire_sound = 'ModularTegustation/Tegusounds/weapons/guns/ak47.ogg'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	zoomable = TRUE
	zoom_amt = 8
	zoom_out_amt = 4
	burst_size = 1

/obj/item/gun/ballistic/automatic/sr25/Initialize()
	. = ..()
	fire_delay = 6
