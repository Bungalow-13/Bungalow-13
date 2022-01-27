GLOBAL_LIST_EMPTY(infection_spawns)

// Power verbs

/mob/camera/commander/proc/place_infection_core()
	if(placed)
		return
	var/turf/start = pick(GLOB.infection_spawns)
	if(!start)
		qdel(src)
		message_admins("Unable to find spawn position for infection core.")
		return
	var/obj/effect/meteor/infection/M = new/obj/effect/meteor/infection(start, start, src)
	M.pixel_x = pick(-32, 32)
	M.pixel_y = pick(-32, 32)
	M.pixel_z = 270
	new /obj/effect/temp_visual/dragon_swoop(M.loc)
	animate(M, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 10)
	qdel(M)

/obj/effect/landmark/infection_start
	name = "infectionstart"
	icon_state = "infection_start"

/obj/effect/landmark/infection_start/Initialize(mapload)
	..()
	GLOB.infection_spawns += get_turf(src)
	return INITIALIZE_HINT_QDEL

/obj/effect/meteor/infection
	name = "infectious core"
	desc = "It's bright."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_shield"
	heavy = 1
	var/mob/camera/commander/overmind = null

/obj/effect/meteor/infection/Destroy()
	var/obj/structure/infection/core/I = new(get_turf(src), overmind, overmind.base_point_rate, 1)
	overmind.infection_core = I
	I.update_icon()
	overmind.update_health_hud()
	overmind.reset_perspective()
	overmind.transport_core()
	overmind.placed = 1
	overmind.meteor = null
	meteor_effect()
	return ..()

/obj/effect/meteor/infection/Initialize(mapload, target, temp)
	if(!iscommander(temp))
		return
	overmind = temp
	var/mutable_appearance/infection_overlay = mutable_appearance('icons/mob/blob.dmi', "blob_shield")
	infection_overlay.color = overmind.infection_color
	add_overlay(infection_overlay)
	add_overlay(mutable_appearance('icons/mob/blob.dmi', "blob_core_overlay"))
	overmind.reset_perspective(src)
	overmind.meteor = src
	. = ..()

/obj/effect/meteor/infection/get_hit()
	return

/obj/effect/meteor/infection/Move()
	if(!overmind.infection_core)
		overmind.forceMove(get_turf(src))

/mob/camera/commander/proc/can_buy(cost = 15)
	if(infection_points < cost)
		to_chat(src, "<span class='warning'>You cannot afford this, you need at least [cost] resources!</span>")
		return 0
	add_points(-cost)
	return 1

/mob/camera/commander/verb/transport_core()
	set category = "Infection"
	set name = "Jump to Core"
	set desc = "Move your camera to your core."
	if(infection_core)
		forceMove(infection_core.drop_location())

/mob/camera/commander/verb/jump_to_node()
	set category = "Infection"
	set name = "Jump to Node"
	set desc = "Move your camera to a selected node."
	if(GLOB.infection_nodes.len)
		var/list/nodes = list()
		for(var/i in 1 to GLOB.infection_nodes.len)
			var/obj/structure/infection/node/N = GLOB.infection_nodes[i]
			nodes["Infection Node #[i]"] = N
		var/node_name = input(src, "Choose a node to jump to.", "Node Jump") in nodes
		var/obj/structure/infection/node/chosen_node = nodes[node_name]
		if(chosen_node)
			forceMove(chosen_node.loc)

/mob/camera/commander/proc/createSpecial(price, infectionType, nearEquals, needsNode, turf/T)
	if(!T)
		T = get_turf(src)
	var/obj/structure/infection/I = (locate(/obj/structure/infection) in T)
	if(!I)
		to_chat(src, "<span class='warning'>There is no infection here!</span>")
		return
	if(!istype(I, /obj/structure/infection/normal))
		to_chat(src, "<span class='warning'>Unable to use this infection, find a normal one.</span>")
		return
	if(needsNode && nodes_required)
		if(!(locate(/obj/structure/infection/node) in orange(3, T)) && !(locate(/obj/structure/infection/core) in orange(4, T)))
			to_chat(src, "<span class='warning'>You need to place this infection closer to a node or core!</span>")
			return //handholdotron 2000
	if(nearEquals)
		for(var/obj/structure/infection/L in orange(nearEquals, T))
			if(L.type == infectionType)
				to_chat(src, "<span class='warning'>There is a similar infection nearby, move more than [nearEquals] tiles away from it!</span>")
				return
	if(!can_buy(price))
		return
	var/obj/structure/infection/N = I.change_to(infectionType, src)
	return N

/mob/camera/commander/verb/toggle_node_req()
	set category = "Infection"
	set name = "Toggle Node Requirement"
	set desc = "Toggle requiring nodes to place resource and factory infections."
	nodes_required = !nodes_required
	if(nodes_required)
		to_chat(src, "<span class='warning'>You now require a nearby node or core to place factory and resource infections.</span>")
	else
		to_chat(src, "<span class='warning'>You no longer require a nearby node or core to place factory and resource infections.</span>")

/mob/camera/commander/verb/create_shield_power()
	set category = "Infection"
	set name = "Create Shield Infection (15)"
	set desc = "Create a shield infection, which will block fire and is hard to kill."
	create_shield()

/mob/camera/commander/proc/create_shield(turf/T)
	createSpecial(15, /obj/structure/infection/shield, 0, 0, T)

/mob/camera/commander/verb/create_resource()
	set category = "Infection"
	set name = "Create Resource Infection (40)"
	set desc = "Create a resource tower which will generate resources for you."
	createSpecial(40, /obj/structure/infection/resource, 4, 1)

/mob/camera/commander/verb/create_node()
	set category = "Infection"
	set name = "Create Node Infection (50)"
	set desc = "Create a node, which will power nearby factory and resource infections."
	createSpecial(50, /obj/structure/infection/node, 5, 0)

/mob/camera/commander/verb/create_factory()
	set category = "Infection"
	set name = "Create Factory Infection (60)"
	set desc = "Create a spore tower that will spawn spores to harass your enemies."
	createSpecial(60, /obj/structure/infection/factory, 7, 1)

/mob/camera/commander/verb/create_turret()
	set category = "Infection"
	set name = "Create Turret Infection (70)"
	set desc = "Create a turret that will fire at enemies."
	createSpecial(70, /obj/structure/infection/turret, 8, 1)

/mob/camera/commander/proc/create_spore()
	upgrade_points--
	to_chat(src, "<span class='warning'>Attempting to create a sentient spore...</span>")
	var/turf/T = get_turf(infection_core)

	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as a sentient infection spore?", ROLE_INFECTION, null, ROLE_INFECTION, 50) //players must answer rapidly
	if(LAZYLEN(candidates)) //if we got at least one candidate, they're a sentient spore now.
		var/mob/living/simple_animal/hostile/infection/infectionspore/spore = new /mob/living/simple_animal/hostile/infection/infectionspore(T.loc)
		spore.forceMove(T)
		spore.overmind = src
		spore.update_icons()
		spore.adjustHealth(spore.maxHealth * 0.5)
		infection_mobs += spore
		var/mob/dead/observer/C = pick(candidates)
		spore.key = C.key
		SEND_SOUND(spore, sound('sound/effects/blobattack.ogg'))
		SEND_SOUND(spore, sound('sound/effects/attackblob.ogg'))
		spore.infection_help()
		return TRUE
	to_chat(src, "<span class='warning'>You could not conjure a sentience for your spore. Try again later.</span>")
	upgrade_points++

/mob/camera/commander/verb/evolve_menu()
	set category = "Infection"
	set name = "Evolution"
	set desc = "Improve yourself and your army to be unstoppable."
	if(upgrade_points > 0)
		var/list/choices = list(
			"Summon Sentient Spore (1)" = image(icon = 'icons/mob/blob.dmi', icon_state = "blobpod"),
			"Ability Unlocks" = image(icon = 'icons/mob/blob.dmi', icon_state = "ui_increase"),
			"Effect Unlocks" = image(icon = 'icons/mob/blob.dmi', icon_state = "blob_core_overlay"),
		)
		var/choice = show_radial_menu(src, src, choices, tooltips = TRUE)
		if(choice == "Summon Sentient Spore (1)")
			create_spore()
		else if(choice == "Structure Upgrades")
			return
		else if(choice == "Effect Unlocks")
			// add stuff like
			// stronger natural core defenses
			// extra point for spore evolution?
			// natural resistance to fire based attacks
			// other stuff idk
			return
	else
		to_chat(src, "We lack the necessary resources to upgrade ourself. Absorb the beacons to gain their power.")

/mob/camera/commander/verb/revert()
	set category = "Infection"
	set name = "Remove Infection"
	set desc = "Removes an infection, giving you back some resources."
	var/turf/T = get_turf(src)
	remove_infection(T)

/mob/camera/commander/proc/remove_infection(turf/T)
	var/obj/structure/infection/I = locate() in T
	if(!I)
		to_chat(src, "<span class='warning'>There is no infection there!</span>")
		return
	if(I.point_return < 0)
		to_chat(src, "<span class='warning'>Unable to remove this infection.</span>")
		return
	if(I.point_return)
		add_points(I.point_return)
		to_chat(src, "<span class='notice'>Gained [I.point_return] resources from removing \the [I].</span>")
	qdel(I)

/mob/camera/commander/verb/expand_infection_power()
	set category = "Infection"
	set name = "Expand/Attack Infection (4)"
	set desc = "Attempts to create a new infection in this tile. If the tile isn't clear, instead attacks it, damaging mobs and objects."
	var/turf/T = get_turf(src)
	expand_infection(T)

/mob/camera/commander/proc/expand_infection(turf/T)
	if(world.time < last_attack)
		return
	var/list/possibleinfection = list()
	for(var/obj/structure/infection/AI in range(T, 1))
		possibleinfection += AI
	if(!possibleinfection.len)
		to_chat(src, "<span class='warning'>There is no infection adjacent to the target tile!</span>")
		return
	if(can_buy(4))
		var/attacksuccess = FALSE
		for(var/mob/living/L in T)
			if(ROLE_INFECTION in L.faction) //no friendly/dead fire
				continue
			if(L.stat != DEAD)
				attacksuccess = TRUE
		var/obj/structure/infection/I = locate() in T
		if(I)
			if(!attacksuccess) //if we successfully attacked a turf with an infection on it, don't refund shit
				to_chat(src, "<span class='warning'>There is an infection there!</span>")
				add_points(4) //otherwise, refund all of the cost
		else
			var/obj/structure/infection/IB = pick(possibleinfection)
			IB.expand(T, src)
		if(attacksuccess)
			last_attack = world.time + CLICK_CD_MELEE
		else
			last_attack = world.time + CLICK_CD_RAPID

/mob/camera/commander/verb/rally_spores_power()
	set category = "Infection"
	set name = "Rally Spores"
	set desc = "Rally your spores to move to a target location."
	var/turf/T = get_turf(src)
	rally_spores(T)

/mob/camera/commander/proc/rally_spores(turf/T)
	to_chat(src, "You direct your selected spores.")
	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return
	for(var/mob/living/simple_animal/hostile/infection/infectionspore/IS in infection_mobs)
		if(isturf(IS.loc) && get_dist(IS, T) <= 35)
			IS.LoseTarget()
			IS.Goto(pick(surrounding_turfs), IS.move_to_delay)

/mob/camera/commander/verb/infection_broadcast()
	set category = "Infection"
	set name = "Infection Broadcast"
	set desc = "Speak with your infection spores and infesternauts as your mouthpieces."
	var/speak_text = input(src, "What would you like to say with your minions?", "Infection Broadcast", null) as text
	if(!speak_text)
		return
	else
		to_chat(src, "You broadcast with your minions, <B>[speak_text]</B>")
	for(var/INF in infection_mobs)
		var/mob/living/simple_animal/hostile/infection/IN = INF
		if(IN.stat == CONSCIOUS)
			IN.say(speak_text)

/mob/camera/commander/verb/infection_help()
	set category = "Infection"
	set name = "*Infection Help*"
	set desc = "Help on how to infection."
	to_chat(src, "<b>As the commander, you command the nearly impossible to kill infection!</b>")
	to_chat(src, "<b>Your job is to delegate resources. Upgrade your defenses and create an army of sentient spores. Protect the boss creatures and destroy the beacons to win.</b>")
	to_chat(src, "<i>Normal Infections</i> will expand your reach and can be upgraded into special infections that perform certain functions.")
	to_chat(src, "<b>You can upgrade normal infections into the following types of infection:</b>")
	to_chat(src, "<i>Shield Infections</i> are bulky infections that can take a beating. You can upgrade them to make them resistant to more effects and gain more maximum health.")
	to_chat(src, "<i>Resource Infections</i> produce 1 resource every couple of seconds for you. They produce 2 more resources for each time they are upgraded.")
	to_chat(src, "<i>Factory Infections</i> produce mindless spores that obey you and attack intruders. Factories produce 2 more spores for each time they are ugpraded.")
	to_chat(src, "<i>Sentient Spores</i> are constantly evolving creatures that do not die as long as you live, they simply regenerate themselves from you.")
	to_chat(src, "<i>Node Infections</i> constantly grow more infections around them. When upgraded they spread faster, though they expand slower as they age. These are the only way you can damage the beacons when they spread on them.")
	to_chat(src, "<b>In addition to the buttons on your HUD, there are a few click shortcuts to speed up expansion and defense.</b>")
	to_chat(src, "<b>Shortcuts:</b> Click = Upgrade Infection (Must be near infection) <b>|</b> Middle Mouse Click = Move selected spores <b>|</b> Ctrl Click = Create Shield Infection <b>|</b> Alt Click = Remove Infection")
	if(!placed && autoplace_time <= world.time)
		to_chat(src, "<span class='big'><font color=\"#EE4000\">You will automatically place your core in [DisplayTimeText(max(autoplace_time - world.time, 0))].</font></span>")
