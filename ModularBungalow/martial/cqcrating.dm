#define TOSS_COMBO "HGD"
#define LAUNCH_COMBO "HHH"
#define HEAVYFIST_COMBO "GDH"
#define CARGO_COMBO "HGHHG"

/datum/martial_art/qm
	name = "Close Quarters Crating"
	id = MARTIALART_QM
	help_verb = /mob/living/proc/QM_help
	display_combos = TRUE

/datum/martial_art/qm/proc/check_streak(mob/living/A, mob/living/D)
	if(findtext(streak,TOSS_COMBO))
		streak = ""
		Toss(A,D)
		return TRUE
	if(findtext(streak,LAUNCH_COMBO))
		streak = ""
		Launch(A,D)
		return TRUE
	if(findtext(streak,HEAVYFIST_COMBO))
		streak = ""
		Punch(A,D)
		return TRUE
	if(findtext(streak,CARGO_COMBO))
		streak = ""
		Cargo(A,D)
		return TRUE
	return FALSE

/datum/martial_art/qm/proc/Toss(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		D.visible_message("<span class='danger'>[A] toss [D] back!</span>", \
						"<span class='userdanger'>You're thrown back by [A]!</span>", COMBAT_MESSAGE_RANGE, A)
		to_chat(A, "<span class='danger'>You toss [D] back!</span>")
		playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
		var/atom/throw_target = get_edge_target_turf(D, A.dir)
		D.throw_at(throw_target, 6, 25, A)
		log_combat(A, D, "tossed (CQC)")
	return TRUE


/datum/martial_art/qm/proc/Launch(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		D.visible_message("<span class='danger'>[A] slams their body into [D]!</span>", \
						"<span class='userdanger'>[A] slams their body ito you!!</span>", COMBAT_MESSAGE_RANGE, A)
		to_chat(A, "<span class='danger'>You throw all your weight into [D]!</span>")
		playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
		var/atom/throw_target = get_edge_target_turf(D, A.dir)
		D.throw_at(throw_target, 2, 10, A)
		D.apply_damage(10, A.get_attack_type())
		log_combat(A, D, "attacked (CQC)")
	return TRUE


/datum/martial_art/qm/proc/Punch(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		var/atk_verb
		to_chat(A, "<span class='spider'>You begin to wind up an attack...</span>")
		if(!do_after(A, 8, target = D))
			to_chat(A, "<span class='spider'><b>Your attack was interrupted!</b></span>")
			return TRUE //martial art code was a mistake
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		atk_verb = pick("punch", "smash", "crack")
		D.visible_message("<span class='danger'>[A] [atk_verb]ed [D] with such inhuman strength that it sends [D.p_them()] flying backwards!</span>", \
						"<span class='userdanger'>You're [atk_verb]ed by [A] with such inhuman strength that it sends you flying backwards!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", null, A)
		to_chat(A, "<span class='danger'>You [atk_verb] [D] with such inhuman strength that it sends [D.p_them()] flying backwards!</span>")
		D.apply_damage(rand(7,18), A.get_attack_type())
		playsound(D, 'sound/effects/meteorimpact.ogg', 25, TRUE, -1)
		var/throwtarget = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
		D.throw_at(throwtarget, 4, 2, A)//So stuff gets tossed around at the same time.
		D.Paralyze(20)
		if(atk_verb)
			log_combat(A, D, "[atk_verb] (CQC Punch)")
		return TRUE
	return TRUE


/datum/martial_art/qm/proc/Cargo(mob/living/A, mob/living/D)
	D.forceMove(A.loc)
	D.setDir(get_dir(D, A))
	D.Stun(80)
	D.visible_message("<span class='danger'>[A] starts spinning around with [D]!</span>", \
					"<span class='userdanger'>You're spun around by [A]!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", null, A)
	to_chat(A, "<span class='danger'>You start spinning around with [D]!</span>")
	A.emote("scream")

	for (var/i = 0, i < 20, i++)
		var/delay = 5
		switch (i)
			if (17 to INFINITY)
				delay = 0.25
			if (14 to 16)
				delay = 0.5
			if (9 to 13)
				delay = 1
			if (5 to 8)
				delay = 2
			if (0 to 4)
				delay = 3

		if (A && D)

			if (get_dist(A, D) > 1)
				to_chat(A, "<span class='warning'>[D] is too far away!</span>")
				return

			if (!isturf(A.loc) || !isturf(D.loc))
				to_chat(A, "<span class='warning'>You can't throw [D] from here!</span>")
				return

			A.setDir(turn(A.dir, 90))
			var/turf/T = get_step(A, A.dir)
			var/turf/S = D.loc
			if ((S && isturf(S) && S.Exit(D)) && (T && isturf(T) && T.Enter(A)))
				D.forceMove(T)
				D.setDir(get_dir(D, A))
		else
			return

		sleep(delay)

	if (A && D)
		// These are necessary because of the sleep call.

		if (get_dist(A, D) > 1)
			to_chat(A, "<span class='warning'>[D] is too far away!</span>")
			return

		if (!isturf(A.loc) || !isturf(D.loc))
			to_chat(A, "<span class='warning'>You can't throw [D] from here!</span>")
			return

		D.forceMove(A.loc) // Maybe this will help with the wallthrowing bug.

		D.visible_message("<span class='danger'>[A] throws [D]!</span>", \
						"<span class='userdanger'>You're thrown by [A]!</span>", "<span class='hear'>You hear aggressive shuffling and a loud thud!</span>", null, A)
		to_chat(A, "<span class='danger'>You throw [D]!</span>")
		playsound(A.loc, "swing_hit", 50, TRUE)
		var/turf/T = get_edge_target_turf(A, A.dir)
		if (T && isturf(T))
			if (!D.stat)
				D.emote("scream")
			D.throw_at(T, 10, 4, A, TRUE, TRUE, callback = CALLBACK(D, TYPE_PROC_REF(/mob/living, Paralyze), 20))
	log_combat(A, D, "has thrown with wrestling")
	return


/datum/martial_art/qm/harm_act(mob/living/A, mob/living/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/qm/disarm_act(mob/living/A, mob/living/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/qm/grab_act(mob/living/A, mob/living/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE


/mob/living/proc/QM_help()
	set name = "Remember The Basics"
	set desc = "You try to remember some of the basics of CQC."
	set category = "CQC"
	to_chat(usr, "<b><i>You try to remember some of the basics of CQC.</i></b>")

	to_chat(usr, "<span class='notice'>Toss</span>: Harm Grab Disarm. Toss your opponent really far.")
	to_chat(usr, "<span class='notice'>Launch</span>: Harm Harm Harm. throw your whole body into your opponennt, knocking them away.")
	to_chat(usr, "<span class='notice'>Heavyfist Punch</span>: Grab Disarm Harm. Throw your back into a hefty punch.")
	to_chat(usr, "<span class='notice'>Cargo Special</span>: Harm Grab Harm Harm Grab. Spin your opponents and then send them far!")



