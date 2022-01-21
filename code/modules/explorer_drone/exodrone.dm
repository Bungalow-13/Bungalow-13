#define EXODRONE_LOG_SIZE 15

#define EXODRONE_CARGO_SLOTS 6

#define FUEL_BASIC "basic"
#define BASIC_FUEL_TIME_COST 300

#define FUEL_ADVANCED "advanced"
#define ADVANCED_FUEL_TIME_COST 200

#define FUEL_EXOTIC "exotic"
#define EXOTIC_FUEL_TIME_COST 100

GLOBAL_LIST_EMPTY(exodrones)
GLOBAL_LIST_EMPTY(exodrone_launchers)
/// Tool to fa icon name
GLOBAL_LIST_INIT(all_exodrone_tools,list(
	EXODRONE_TOOL_WELDER = "burn",
	EXODRONE_TOOL_TRANSLATOR = "language",
	EXODRONE_TOOL_LASER = "bolt",
	EXODRONE_TOOL_MULTITOOL = "broadcast-tower",
	EXODRONE_TOOL_DRILL = "screwdriver",
))

/// Exploration drone
/obj/item/exodrone
	name = "exploration drone"
	desc = "long range semi-autonomous exploration drone"
	icon = 'icons/obj/exploration.dmi'
	icon_state = "drone"
	w_class = WEIGHT_CLASS_BULKY

	var/drone_status = EXODRONE_IDLE
	/// Are we currently controlled by remote terminal
	var/controlled = FALSE
	/// Site we're currently at or traveling from, null means station.
	var/datum/exploration_site/location
	/// Site we're currently travelling to, null means going back to station - check drone status if you want to check if traveling or idle
	var/datum/exploration_site/travel_target
	/// Full travel time in ds to our current target
	var/travel_time
	/// Id of travel timer
	var/travel_timer_id

	/// Message that will show up on busy screen
	var/busy_message = "Doing something..."
	/// When we entered busy state
	var/busy_start_time
	/// How long will busy state last
	var/busy_duration
	// Our current adventure if any.
	var/datum/adventure/current_adventure
	// Our current simple event data if any
	var/list/current_event_ui_data
	/// Pad we've launched from, we'll try to land on this one first when coming back if it still exists.
	var/datum/weakref/last_pad
	/// Log of recent events
	var/list/drone_log = list()

	/// List of tools
	var/list/tools = list()

	// Cost per 1 distance in deciseconds
	var/travel_cost_coeff = BASIC_FUEL_TIME_COST
	/// Name counter
	var/static/name_counter = list()

/obj/item/exodrone/Initialize()
	. = ..()
	name = pick(strings(EXODRONE_FILE,"probe_names"))
	if(name_counter[name])
		name = "[name] \Roman[++name_counter[name]]"
	else
		name_counter[name] = 1
	GLOB.exodrones += src
	/// Cargo storage
	var/datum/component/storage/storage = AddComponent(/datum/component/storage/concrete)
	storage.cant_hold = GLOB.blacklisted_cargo_types
	storage.max_w_class = WEIGHT_CLASS_NORMAL
	storage.max_items = EXODRONE_CARGO_SLOTS

/obj/item/exodrone/Destroy()
	. = ..()
	GLOB.exodrones -= src

/// Description for drone listing, describes location and current status
/obj/item/exodrone/proc/ui_description()
	if(location)
		switch(drone_status)
			if(EXODRONE_TRAVEL)
				return "Traveling back to station"
			else
				return "Exploring [location.display_name()]"
	else
		switch(drone_status)
			if(EXODRONE_TRAVEL)
				return "Traveling to exploration site."
			else
				return "Idle"
				//If loc == launch_pad : "Docked at Launch pad X"

/// Is the drone ready to start traveling for exploration site
/obj/item/exodrone/proc/ready_to_launch()
	var/obj/machinery/exodrone_launcher/pad = locate() in loc
	return pad && pad.fuel_canister != null

/obj/item/exodrone/proc/launch_for(datum/exploration_site/target_site)
	if(!location) //We're launching from station, fuel up
		var/obj/machinery/exodrone_launcher/pad = locate() in loc
		pad.fuel_up(src)
		last_pad = WEAKREF(pad)
		drone_log("Launched from [pad.name] and set course for [target_site.display_name()]")
	else
		drone_log("Launched from [location.display_name()] and set course for [target_site.display_name()]")
	start_travel(target_site)

/obj/item/exodrone/proc/set_status(new_status)
	SEND_SIGNAL(src,COMSIG_EXODRONE_STATUS_CHANGED)
	drone_status = new_status

/obj/item/exodrone/proc/space_left()
	return EXODRONE_CARGO_SLOTS - length(contents) - length(tools)

/obj/item/exodrone/proc/add_tool(tool_type)
	if(space_left() > 0 && (tool_type in GLOB.all_exodrone_tools))
		tools += tool_type
		update_storage_size()

/obj/item/exodrone/proc/remove_tool(tool_type)
	tools -= tool_type
	update_storage_size()

/obj/item/exodrone/proc/update_storage_size()
	var/datum/component/storage/storage = GetComponent(/datum/component/storage/concrete)
	storage.max_items = EXODRONE_CARGO_SLOTS - length(tools)

/obj/item/exodrone/proc/get_cargo_data()
	. = list()
	for(var/tool in tools)
		. += list(list("type"="tool","name"=tool))
	for(var/obj/cargo in contents)
		. += list(list("type"="cargo","name"=cargo.name))
	for(var/_ in 1 to space_left())
		. += list(list("type"="empty","name"="Free space"))

/// Tries to add loot to drone cargo respecting space left
/obj/item/exodrone/proc/try_transfer(obj/loot, delete_on_failure=TRUE)
	if(space_left() > 1)
		loot.forceMove(src)
		drone_log("Acquired [loot.name].")
	else
		drone_log("Abandoned [loot.name] due to lack of space.")
		if(delete_on_failure)
			qdel(loot)

/obj/item/exodrone/proc/get_possible_tools()
	return list(null,EXODRONE_TOOL_WELDER,EXODRONE_TOOL_LASER,EXODRONE_TOOL_TRANSLATOR,EXODRONE_TOOL_DRILL,EXODRONE_TOOL_MULTITOOL)

/// Starts travel mode for the given target
/obj/item/exodrone/proc/start_travel(datum/exploration_site/target_site)
	set_status(EXODRONE_TRAVEL)
	moveToNullspace()
	var/distance_to_travel = target_site ? target_site.distance : location.distance //If we're going home distance is distance of our current location
	if(location && target_site) //Traveling site to site is faster (don't think too hard on 3d space logistics here)
		distance_to_travel = max(abs(target_site.distance - location.distance),1)
	travel_target = target_site
	travel_time = travel_cost_coeff*distance_to_travel
	travel_timer_id = addtimer(CALLBACK(src,.proc/finish_travel),travel_time,TIMER_STOPPABLE)

/obj/item/exodrone/proc/finish_travel()
	location = travel_target
	travel_timer_id = null
	travel_time = null
	if(location)//We're arriving at exploration site
		location.on_drone_arrival(src)
		set_status(EXODRONE_EXPLORATION)
	else
		var/obj/machinery/exodrone_launcher = find_unused_pad()
		if(exodrone_launcher)
			forceMove(get_turf(exodrone_launcher))
			drone_log("Arrived at [station_name()]. Landing at [exodrone_launcher]")
		else
			var/turf/drop_zone = drop_somewhere_on_station()
			drone_log("Arrived at [station_name()]. Emergency landing at [drop_zone.loc.name]")
		set_status(EXODRONE_IDLE)

/obj/item/exodrone/proc/drop_somewhere_on_station()
	var/turf/random_spot = get_safe_random_station_turf()
	var/obj/structure/closet/supplypod/pod = new
	new /obj/effect/pod_landingzone(random_spot, pod, src)
	return random_spot

/obj/item/exodrone/proc/find_unused_pad()
	var/obj/machinery/exodrone_launcher/landing_pad = last_pad?.resolve()
	if(landing_pad)
		return landing_pad
	for(var/obj/machinery/exodrone_launcher/other_pad in GLOB.exodrone_launchers)
		return other_pad

/obj/item/exodrone/proc/explore_site(datum/exploration_event/specific_event)
	if(!specific_event) //Ecounter random event
		var/list/events_to_ecounter = list()
		for(var/datum/exploration_event/event in location.events)
			if(event.visited)
				continue
			events_to_ecounter += event
		if(!length(events_to_ecounter))
			drone_log("It seems there's nothing interesting left around [location.name]")
			return
		var/datum/exploration_event/ecountered_event = pick(events_to_ecounter)
		ecountered_event.ecounter(src)
	else if(specific_event.is_targetable())
		specific_event.ecounter(src)

/obj/item/exodrone/proc/get_adventure_data()
	return current_adventure?.ui_data()

/obj/item/exodrone/proc/start_adventure(datum/adventure/adventure)
	current_adventure = adventure
	RegisterSignal(current_adventure,COMSIG_ADVENTURE_FINISHED,.proc/resolve_adventure)
	RegisterSignal(current_adventure,COMSIG_ADVENTURE_QUALITY_INIT,.proc/add_tool_qualities)
	RegisterSignal(current_adventure,COMSIG_ADVENTURE_DELAY_START,.proc/adventure_delay_start)
	RegisterSignal(current_adventure,COMSIG_ADVENTURE_DELAY_END,.proc/adventure_delay_end)
	set_status(EXODRONE_ADVENTURE)
	current_adventure.start_adventure()

/// Handles finishing adventure
/obj/item/exodrone/proc/resolve_adventure(datum/source,result)
	SIGNAL_HANDLER
	switch(result)
		if(ADVENTURE_RESULT_SUCCESS)
			award_adventure_loot()
			UnregisterSignal(current_adventure,list(COMSIG_ADVENTURE_FINISHED,COMSIG_ADVENTURE_QUALITY_INIT,COMSIG_ADVENTURE_DELAY_START,COMSIG_ADVENTURE_DELAY_END))
			current_adventure = null
			set_status(EXODRONE_EXPLORATION)
			return
		if(ADVENTURE_RESULT_DAMAGE)
			damage(max_integrity*0.5) //Half health lost
			if(!QDELETED(src)) // Don't bother if we just blown up from the damage
				UnregisterSignal(current_adventure,list(COMSIG_ADVENTURE_FINISHED,COMSIG_ADVENTURE_QUALITY_INIT,COMSIG_ADVENTURE_DELAY_START,COMSIG_ADVENTURE_DELAY_END))
				current_adventure = null
				set_status(EXODRONE_EXPLORATION)
			return
		if(ADVENTURE_RESULT_DEATH)
			qdel(src)

/// Adds loot from current adventure to the drone
/obj/item/exodrone/proc/award_adventure_loot()
	if(length(current_adventure.loot_categories))
		var/generator_type = GLOB.adventure_loot_generator_index[pick(current_adventure.loot_categories)]
		if(!generator_type)
			return //Could probably warn but i suppose this is up to adventure creator.
		var/datum/adventure_loot_generator/generator = new generator_type
		generator.transfer_loot(src)

/// Applies adventure qualities based on our tools
/obj/item/exodrone/proc/add_tool_qualities(datum/source,list/quality_list)
	SIGNAL_HANDLER
	for(var/tool in tools)
		quality_list[tool] = 1

/obj/item/exodrone/proc/adventure_delay_start(datum/source, delay_time,delay_message)
	SIGNAL_HANDLER
	set_busy(delay_message,delay_time)

/obj/item/exodrone/proc/adventure_delay_end(datum/source)
	unset_busy(EXODRONE_ADVENTURE)

/obj/item/exodrone/proc/set_busy(message,duration)
	if(message)
		busy_message = message
	busy_start_time = world.time
	busy_duration = duration
	set_status(EXODRONE_BUSY)

/obj/item/exodrone/proc/unset_busy(new_status)
	busy_message = initial(busy_message)
	busy_start_time = null
	busy_duration = null
	set_status(new_status)

/obj/item/exodrone/proc/busy_time_left()
	return busy_duration - (world.time - busy_start_time)

/// Can the drone start traveling now
/obj/item/exodrone/proc/can_travel()
	/// We're home and on ready pad or exploring and out of any events/adventures
	return (drone_status == EXODRONE_IDLE && ready_to_launch()) || (drone_status == EXODRONE_EXPLORATION && current_event_ui_data == null)

/obj/item/exodrone/proc/go_home()
	start_travel(null)
	drone_log("Caculated and executed course for [station_name()].")

/// Deal damage in adventures/events
/obj/item/exodrone/proc/damage(amount)
	take_damage(amount)
	drone_log("Sustained [amount] damage.")

/obj/item/exodrone/proc/drone_log(message)
	drone_log.Insert(1,message)
	if(length(drone_log) > EXODRONE_LOG_SIZE)
		drone_log.Cut(EXODRONE_LOG_SIZE)

/obj/item/exodrone/proc/has_tool(tool_type)
	return tools.Find(tool_type)

/obj/machinery/exodrone_launcher
	name = "exploration drone launcher"
	icon = 'icons/obj/exploration.dmi'
	icon_state = "launcher"

	var/obj/item/fuel_pellet/fuel_canister

	///Our turf, drones entering it will use our fuel type
	var/turf/tracked_turf

/obj/machinery/exodrone_launcher/Initialize()
	. = ..()
	GLOB.exodrone_launchers += src

/obj/machinery/exodrone_launcher/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/fuel_pellet))
		if(fuel_canister)
			to_chat(user, "<span class='warning'>There's already a fuel tank inside [src]!</span>")
			return TRUE
		if(!user.transferItemToLoc(I, src))
			return
		fuel_canister = I
		update_icon()
		return TRUE
	else if(istype(I,/obj/item/exodrone) && user.transferItemToLoc(I, drop_location()))
		return TRUE
	else
		return ..()

/obj/machinery/exodrone_launcher/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(fuel_canister)
		to_chat(user, "<span class='notie'>You remove the fuel tank from [src].</span>")
		fuel_canister.forceMove(drop_location())
		fuel_canister = null

/obj/machinery/exodrone_launcher/Destroy()
	. = ..()
	GLOB.exodrone_launchers -= src

/obj/machinery/exodrone_launcher/update_overlays()
	. = ..()
	if(fuel_canister)
		switch(fuel_canister.fuel_type)
			if(FUEL_BASIC)
				. += "launchpad_fuel_basic"
			if(FUEL_ADVANCED)
				. += "launchpad_fuel_advanced"
			if(FUEL_EXOTIC)
				. += "launchpad_fuel_exotic"

/obj/machinery/exodrone_launcher/proc/get_fuel_coefficent()
	if(!fuel_canister)
		return
	switch(fuel_canister.fuel_type)
		if(FUEL_BASIC)
			return BASIC_FUEL_TIME_COST
		if(FUEL_ADVANCED)
			return ADVANCED_FUEL_TIME_COST
		if(FUEL_EXOTIC)
			return EXOTIC_FUEL_TIME_COST

/obj/machinery/exodrone_launcher/proc/fuel_up(obj/item/exodrone/drone)
	drone.travel_cost_coeff = get_fuel_coefficent()
	fuel_canister.use()

/obj/machinery/exodrone_launcher/handle_atom_del(atom/A)
	if(A == fuel_canister)
		fuel_canister = null
		update_icon()

/obj/item/exodrone/proc/get_travel_coeff()
	switch(drone_status)
		if(EXODRONE_IDLE)
			var/obj/machinery/exodrone_launcher/pad = locate() in loc
			if(pad && pad.fuel_canister)
				return pad.get_fuel_coefficent()
			else
				return travel_cost_coeff
		else
			return travel_cost_coeff

/*
	TODO crystalizer recipes for these, suggessted:
	o2/plasma = basic
	trit/h2 = medium
	hypernob/stim = advanced
	stim/helium = exotic
	hypernob/antinob = ultimate
*/

/obj/item/fuel_pellet
	name = "standard fuel pellet"
	desc = "compressed fuel pellet for long-distance flight"
	icon = 'icons/obj/exploration.dmi'
	icon_state = "fuel_basic"
	var/fuel_type = FUEL_BASIC
	var/uses = 5

/obj/item/fuel_pellet/use()
	uses--
	if(uses < 0)
		qdel(src)

/obj/item/fuel_pellet/advanced
	fuel_type = FUEL_ADVANCED
	icon_state = "fuel_advanced"

/obj/item/fuel_pellet/exotic
	fuel_type = FUEL_EXOTIC
	icon_state = "fuel_exotic"

/datum/supply_pack/misc/exploration_drone
	name = "Exploration Drone"
	desc = "A replacement long-range exploration drone."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/exodrone)
	crate_name = "exodrone crate"
