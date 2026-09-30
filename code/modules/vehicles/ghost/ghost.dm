#define LAYER_OFFSET_ABOVE_BASE 0.1
#define LAYER_OFFSET_LOW 0.2
#define LAYER_OFFSET_ABOVE_LOW 0.3
#define LAYER_OFFSET_HIGH 0.4
#define LAYER_OFFSET_HIGHEST 0.5

/obj/vehicle/multitile/ghost
	name = "Ghost"
	desc = "An M577 Armored Personnel Carrier. An armored transport with four big wheels. Entrances on the sides and back."

	icon = 'icons/halo/obj/covenant_vehicles/ghost.dmi'
	icon_state = "ghost"
	pixel_x = -16
	pixel_y = -16

	bound_width = 64
	bound_height = 64

	bound_x = 0
	bound_y = 0

	interior_map = null

	move_on_turn = TRUE

	can_buckle = TRUE
	buckle_lying = FALSE

	entrance_speed = 0.5 SECONDS

	required_skill = SKILL_VEHICLE_UNTRAINED

	health = 300
	movement_sound = 'sound/vehicles/tank_driving.ogg'

	light_range = 4
	light_color = COLOR_PLASMA_BLUE

	hardpoints_allowed = list(
		/obj/item/hardpoint/primary/ghost_plasma,
		/obj/item/hardpoint/locomotion/hover_system,
	)

	seats = list(
		VEHICLE_DRIVER = null,
	)

	active_hp = list(
		VEHICLE_DRIVER = null,
	)

	vehicle_flags = VEHICLE_CLASS_LIGHT

	explosive_resistance = 20
	dmg_multipliers = list(
		"all" = 1,
		"acid" = 1.6,
		"slash" = 1.8,
		"bullet" = 1.8,
		"explosive" = 3,
		"blunt" = 0.7,
		"abstract" = 1,
	)

	move_max_momentum = 2.5
	move_momentum_build_factor = 1.5
	move_turn_momentum_loss_factor = 0
	//var/datum/looping_sound/som_tank_drive/hover_bike/engine_sound
	var/list/buckled_offsets = list()


/obj/vehicle/multitile/ghost/Initialize(mapload)
	. = ..()
	buckled_offsets = list(
		VEHICLE_DRIVER = list(
			"[NORTH]" = list(16, 4, FALSE),
			"[SOUTH]" = list(16, 25, TRUE),
			"[EAST]" = list(-5, 15, FALSE),
			"[WEST]" = list(21, 15, TRUE)
		)
	)
	//engine_sound = new()
	//AddElement(/datum/element/ridable, /datum/component/riding/vehicle/hover_bike)
	add_filter("shadow", 2, drop_shadow_filter(0, 0, 1))
	//update_icon()

/obj/vehicle/multitile/ghost/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	if(PF)
		PF.flags_pass = PASS_OVER|PASS_FLAGS_CRAWLER

// /obj/vehicle/multitile/ghost/update_overlays()
// 	. = ..()
// 	. += mutable_appearance(icon, "hover_bike_toplayer", TANK_DECORATION_LAYER)
// 	. += mutable_appearance(icon, "hover_bike_midlayer", MOB_ABOVE_PIGGYBACK_LAYER)

/obj/vehicle/multitile/ghost/unbuckle()
	var/mob/M = buckled_mob
	// engine_sound.stop(src)
	. = ..()
	animate_hover(FALSE)
	animate(M)

/obj/vehicle/multitile/ghost/afterbuckle(mob/M)
	. = ..()
	vehicle_faction = M.faction
	M.setDir(dir)
	for(var/obj/item/hardpoint/primary/ghost_plasma/gun in hardpoints)
		active_hp[VEHICLE_DRIVER] = gun
	animate_hover()
	var/datum/action/strafe/strafe_action
	strafe_action = new()
	strafe_action.vehicle = src
	strafe_action.give_to(M)

/obj/vehicle/multitile/ghost/set_seated_mob(seat, mob/living/M)
	seats[seat] = M

	// Checked here because we want to be able to null the mob in a seat
	if(!istype(M))
		return FALSE

	M.set_interaction(src)
	return TRUE

/obj/vehicle/multitile/ghost/add_seated_verbs(mob/living/M, seat)
	if(!M.client)
		return
	add_verb(M.client, list(
		/obj/vehicle/multitile/proc/get_status_info,
		/obj/vehicle/multitile/proc/open_controls_guide
	))
	if(seat == VEHICLE_DRIVER)
		add_verb(M.client, list(
			/obj/vehicle/multitile/proc/switch_hardpoint,
			/obj/vehicle/multitile/proc/cycle_hardpoint,
		))

// /obj/vehicle/multitile/ghost/auto_assign_occupant_flags(mob/M)
// 	. = ..()
// 	if(!is_driver(M))
// 		return
// 	add_control_flags(M, VEHICLE_CONTROL_EQUIPMENT)

// /obj/vehicle/multitile/ghost/welder_act(mob/living/user, obj/item/I)
// 	return welder_repair_act(user, I, 15, 3 SECONDS, fuel_req = 1)

// /obj/vehicle/multitile/ghost/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
// 	explosion(src, light_impact_range = 4, flame_range = (rand(33) ? 3 : 0), explosion_cause=blame_mob)
// 	return ..()

// /obj/vehicle/multitile/ghost/lava_act()
// 	return //we flying baby

/obj/vehicle/multitile/ghost/healthcheck()
	. = ..()
	if(health <= 0)
		animate_hover(FALSE)
		new /obj/effect/temp_visual/plasma_explosion(loc)
		cell_explosion(src.loc, 100, 20, EXPLOSION_FALLOFF_SHAPE_EXPONENTIAL_HALF, null, create_cause_data("ghost explosion"))
	update_icon()

/obj/vehicle/multitile/ghost/try_rotate()
	. = ..()
	if(.)
		update_mob_offsets()

///Animates the bob for the bike and its occupants
/obj/vehicle/multitile/ghost/proc/animate_hover(on = TRUE)
	var/list/hover_list = list(src)
	if(buckled_mob)
		hover_list += buckled_mob
	for(var/atom/atom as anything in hover_list)
		if(!on)
			animate(atom)
			transition_filter("shadow", list(y = 0), 1.2 SECONDS)
			continue
		transition_filter("shadow", list(y = -8), 1.2 SECONDS)
		animate(atom, time = 1.2 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_RELATIVE|ANIMATION_END_NOW, pixel_z = 3)
		animate(time = 1.2 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_RELATIVE, pixel_z = -3)

/obj/vehicle/multitile/ghost/proc/update_mob_offsets()
	for(var/key in seats)
		if(!ismob(seats[key]))
			continue
		var/mob/seated_mob = seats[key]
		var/list/offsets = buckled_offsets[key]["[dir]"]
		seated_mob.pixel_w = offsets[1]
		seated_mob.pixel_z = offsets[2]
		seated_mob.layer = src.layer + (offsets[3] ? LAYER_OFFSET_ABOVE_LOW : LAYER_OFFSET_ABOVE_BASE)
	update_icon()

/obj/effect/vehicle_spawner/ghost
	name = "Ghost Transport Spawner"
	icon = 'icons/obj/vehicles/apc.dmi'
	icon_state = "apc_base"
	pixel_x = -48
	pixel_y = -48

/obj/effect/vehicle_spawner/ghost/Initialize()
	. = ..()
	spawn_vehicle()
	return INITIALIZE_HINT_QDEL

/obj/effect/vehicle_spawner/ghost/spawn_vehicle()
	var/obj/vehicle/multitile/ghost/ghost = new (loc)

	load_misc(ghost)
	load_hardpoints(ghost)
	handle_direction(ghost)
	ghost.update_icon()

/obj/effect/vehicle_spawner/ghost/load_hardpoints(obj/vehicle/multitile/ghost/vehicle)
	vehicle.add_hardpoint(new /obj/item/hardpoint/locomotion/hover_system)
	vehicle.add_hardpoint(new /obj/item/hardpoint/primary/ghost_plasma)


