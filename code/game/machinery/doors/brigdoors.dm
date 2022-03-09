#define CHARS_PER_LINE 5
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Small Fonts"
#define MAX_TIMER 15000 //yogs - changed 9000 to 15000

#define PRESET_SHORT 1200
#define PRESET_MEDIUM 1800
#define PRESET_LONG 3000



///////////////////////////////////////////////////////////////////////////////////////////////
// Brig Door control displays.
//  Description: This is a controls the timer for the brig doors, displays the timer on itself and
//               has a popup window when used, allowing to set the timer.
//  Code Notes: Combination of old brigdoor.dm code from rev4407 and the status_display.dm code
//  Date: 01/September/2010
//  Programmer: Veryinky
/////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/door_timer
	name = "door timer"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	req_access = list(ACCESS_SECURITY)
	density = FALSE
	var/id = null // id of linked machinery/lockers

	var/desired_name = null
	var/desired_crime = null
	var/activation_time = 0
	var/timer_duration = 0

	var/timing = FALSE		// boolean, true/1 timer is on, false/0 means it's not timing
	var/list/obj/machinery/targets = list()
	var/obj/item/radio/Radio //needed to send messages to sec radio

	var/static/list/crimesinfraction = list(
		list(name="Possession, Drugs", tooltip="To possess space drugs or other narcotics by unauthorized personnel.", colour="good",icon="joint",sentence="1800"),
		list(name="Vandalism", tooltip="To deliberately or deface damage the station without malicious intent.", colour="good",icon="car-crash",sentence="1800"),
		list(name="Obstruction of Justice Arrest", tooltip="Any action that corruptly impedes, obstructs or impedes the administration of justice.", colour="good",icon="fist-raised",sentence="1800"),
		list(name="Creating a workplace hazard", tooltip="To endanger the crew or station through negligent or irresponsible, but not deliberately malicious, actions.",colour="good",icon="bomb",sentence="1800"),
		list(name="Insubordination", tooltip="To disobey a lawful direct order from one's superior officer.",colour="good",icon="user-minus",sentence="1800"),
		list(name="Trespass", tooltip="To be in an area which a person does not have access to. This counts for general areas of the ship, and trespass in restricted areas is a more serious crime.", colour="good",icon="door-open",sentence="1800")
	)
	var/static/list/crimesmisdemeanor = list(
		list(name="Assault", tooltip="To use physical force against someone without the apparent intent to kill them.", colour="average",icon="fist-raised",sentence="3000"),
		list(name="Drug Distribution", tooltip="To distribute drug and other controlled substances.", colour="average",icon="tablets",sentence="3000"),
		list(name="Resisting Arrest", tooltip="To not cooperate with an officer who attempts a proper arrest.", colour="average",icon="running",sentence="3000"),
		list(name="Gross Negligence", tooltip="Recklessly acting without reasonable caution and putting another person at risk of injury or death. (Failing to act will result in the same consequences)", colour="average",icon="bolt",sentence="3000"),
		list(name="Petty Theft", tooltip="To take items from areas one does not have access to or to take items belonging to others or the station as a whole.", colour="average",icon="hand-holding",sentence="3000"),
		list(name="Dereliction of Duty", tooltip="To willfully abandon an obligation that is critical to the station's continued operation.",colour="average",icon="walking",sentence="3000"),
		list(name="Breaking and Entry", tooltip="Forced entry to areas where the subject does not have access to. This counts for general areas, and breaking into restricted areas is a more serious crime.",colour="average",icon="door-closed",sentence="3000")
	)
	var/static/list/crimesfelonymisdemeanors = list(
		list(name="Assault, Officer", tooltip="To use physical force against a Department Head or member of Security without the apparent intent to kill them.",colour="average",icon="gavel",sentence="4200"),
		list(name="Possession of a Weapon", tooltip="To be in possession of a dangerous item that is not part of their job role.", colour="average",icon="bolt",sentence="4200"),
		list(name="Drug Synthesis", tooltip="The synthesis of illicit drugs without proper clearance", colour="average",icon="tablets",sentence="4200"),
		list(name="Sabotage", tooltip="To hinder the work of the crew or station through malicious actions.",colour="average",icon="fire",sentence="4200"),
		list(name="Unlawful Assembly", tooltip="The continued assembly of multiple people after being expressly asked to disperse by any member of command, the Detective or the Warden.",colour="average",icon="users",sentence="4200"),
		list(name="Manslaughter", tooltip="To unintentionally kill someone through negligent, but not malicious, actions.",colour="average",icon="skull-crossbones",sentence="4200"),
		list(name="Illegal ID modification", tooltip="The editing of one's access without proper reason or authority",colour="average",icon="card",sentence="4200"),
		list(name="Theft", tooltip="To steal restricted or dangerous items",colour="average",icon="people-carry",sentence="4200"),
		list(name="B&E of a Restricted Area", tooltip="This is breaking into any Security area, Command area (Bridge, EVA, Captains Quarters, Teleporter, etc.), the Engine Room, Atmos, or Toxins research.",colour="average",icon="id-card",sentence="4200"),
		list(name="Rioting", tooltip="To partake in an unauthorized and disruptive assembly of crewmen that refuse to disperse.",colour="average",icon="users",sentence="4200"),
		list(name="Breaking and Entry", tooltip="Forced entry to areas where the subject does not have access to. This counts for general areas, and breaking into restricted areas is a more serious crime.",colour="average",icon="door-closed",sentence="4200")
	)

	maptext_height = 26
	maptext_width = 32
	maptext_y = -1

/obj/machinery/door_timer/Initialize()
	. = ..()

	Radio = new/obj/item/radio(src)
	Radio.listening = 0

/obj/machinery/door_timer/Initialize()
	. = ..()
	if(id != null)
		for(var/obj/machinery/door/window/brigdoor/M in urange(20, src))
			if (M.id == id)
				targets += M

		for(var/obj/machinery/flasher/F in urange(20, src))
			if(F.id == id)
				targets += F

		for(var/obj/structure/closet/secure_closet/brig/C in urange(20, src))
			if(C.id == id)
				targets += C

	if(!targets.len)
		obj_break()
	update_icon()

/obj/machinery/door_timer/attackby(obj/item/W, mob/user, params)
	var/obj/item/card/id/card = W.GetID()
	if (card)
		say("Prisoner name set.")
		desired_name = card.registered_name
	else
		return FALSE

//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
/obj/machinery/door_timer/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(timing)
		if(world.time - activation_time >= timer_duration)
			timer_end() // open doors, reset timer, clear status screen
		update_icon()

// open/closedoor checks if door_timer has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.
/obj/machinery/door_timer/proc/timer_start(mob/user)
	if(machine_stat & (NOPOWER|BROKEN))
		return 0

	activation_time = world.time
	timing = TRUE

	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(door.density)
			continue
		INVOKE_ASYNC(door, /obj/machinery/door/window/brigdoor.proc/close)

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)
			continue
		if(C.opened && !C.close())
			continue
		C.locked = TRUE
		C.update_icon()

	if(desired_crime)
		var/datum/data/record/R = find_record("name", desired_name, GLOB.data_core.security)
		if(R)
			R.fields["criminal"] = "Incarcerated"
			var/crime = GLOB.data_core.createCrimeEntry(desired_crime, null, user.real_name, station_time_timestamp())
			GLOB.data_core.addCrime(R.fields["id"], crime)
			investigate_log("New Crime: <strong>[desired_crime]</strong> | Added to [R.fields["name"]] by [key_name(user)]", INVESTIGATE_RECORDS)
			say("Criminal record for [R.fields["name"]] successfully updated with inputted crime.")
			playsound(loc, 'sound/machines/ping.ogg', 50, 1)
		else if(!desired_name)
			say("No prisoner name inputted, security record not updated.")

	return 1


/obj/machinery/door_timer/proc/timer_end(forced = FALSE)

	if(machine_stat & (NOPOWER|BROKEN))
		return 0

	if(!forced)
		Radio.set_frequency(FREQ_SECURITY)
		Radio.talk_into(src, "Timer has expired. Releasing prisoner.", FREQ_SECURITY)

	timing = FALSE
	activation_time = null
	set_timer(0)
	update_icon()
	var/datum/data/record/R = find_record("name", desired_name, GLOB.data_core.security)
	if(R)
		R.fields["criminal"] = "Discharged"
	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		H.sec_hud_set_security_status()

	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(!door.density)
			continue
		INVOKE_ASYNC(door, /obj/machinery/door/window/brigdoor.proc/open)

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)
			continue
		if(C.opened)
			continue
		C.locked = FALSE
		C.update_icon()

	desired_crime = null
	desired_name = null

	return 1


/obj/machinery/door_timer/proc/time_left(seconds = FALSE)
	. = max(0,timer_duration - (activation_time ? world.time - activation_time : 0))
	if(seconds)
		. /= 10

/obj/machinery/door_timer/proc/set_timer(value)
	var/new_time = clamp(value,0,MAX_TIMER)
	. = new_time == timer_duration //return 1 on no change
	timer_duration = new_time

/obj/machinery/door_timer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BrigTimer", name)
		ui.open()

//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
// if timing=true, run update display function
/obj/machinery/door_timer/update_icon()
	if(machine_stat & (NOPOWER))
		icon_state = "frame"
		return

	if(machine_stat & (BROKEN))
		set_picture("ai_bsod")
		return

	if(timing)
		var/disp1 = id
		var/time_left = time_left(seconds = TRUE)
		var/disp2 = "[add_leading(num2text((time_left / 60) % 60), 2, "0")]:[add_leading(num2text(time_left % 60), 2, "0")]"
		if(length(disp2) > CHARS_PER_LINE)
			disp2 = "Error"
		update_display(disp1, disp2)
	else
		if(maptext)
			maptext = ""
	return


// Adds an icon in case the screen is broken/off, stolen from status_display.dm
/obj/machinery/door_timer/proc/set_picture(state)
	if(maptext)
		maptext = ""
	cut_overlays()
	add_overlay(mutable_appearance('icons/obj/status_display.dmi', state))


//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
/obj/machinery/door_timer/proc/update_display(line1, line2)
	line1 = uppertext(line1)
	line2 = uppertext(line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text

/obj/machinery/door_timer/ui_data()
	var/list/data = list()
	var/time_left = time_left(seconds = TRUE)
	data["seconds"] = round(time_left % 60)
	data["minutes"] = round((time_left - data["seconds"]) / 60)
	data["timing"] = timing
	data["flash_charging"] = FALSE
	data["desired_name"] = desired_name
	data["desired_crime"] = desired_crime
	data["infractionCrimes"] = crimesinfraction
	data["misdemeanorCrimes"] = crimesmisdemeanor
	data["felonymisdemeanorsCrimes"] = crimesfelonymisdemeanors
	for(var/obj/machinery/flasher/F in targets)
		if(F.last_flash && (F.last_flash + 150) > world.time)
			data["flash_charging"] = TRUE
			break
	return data


/obj/machinery/door_timer/ui_act(action, params)
	. = ..()
	if(.)
		return

	. = TRUE

	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return FALSE

	switch(action)
		if("time")
			var/value = text2num(params["adjust"])
			if(value)
				. = set_timer(time_left()+value)
		if("start")
			timer_start(usr)
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				H.sec_hud_set_security_status()
		if("stop")
			timer_end(forced = TRUE)
			for(var/mob/living/carbon/human/H in GLOB.carbon_list)
				H.sec_hud_set_security_status()
		if("flash")
			for(var/obj/machinery/flasher/F in targets)
				F.flash()
		if("preset")
			var/preset = params["preset"]
			var/preset_time = time_left()
			switch(preset)
				if("short")
					preset_time = PRESET_SHORT
				if("medium")
					preset_time = PRESET_MEDIUM
				if("long")
					preset_time = PRESET_LONG
			. = set_timer(preset_time)
			if(timing)
				activation_time = world.time
		if("prisoner_name")
			var/prisoner_name = stripped_input(usr, "Input prisoner's name...", "Crimes", desired_name)
			if(!prisoner_name || !Adjacent(usr))
				return FALSE
			desired_name = prisoner_name
		if("presetCrime")
			var/value = text2num(params["preset"])
			var/preset_crime = "N/A"
			for(var/allcrimes in crimesinfraction + crimesmisdemeanor + crimesfelonymisdemeanors + crimesfelony + crimessevere)
				if(params["crime"] == allcrimes["name"])
					preset_crime = params["crime"]
					break
			desired_crime += preset_crime + ", "
			if(value)
				. = set_timer(time_left()+value)
		else
			. = FALSE


#undef PRESET_SHORT
#undef PRESET_MEDIUM
#undef PRESET_LONG

#undef MAX_TIMER
#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef CHARS_PER_LINE
