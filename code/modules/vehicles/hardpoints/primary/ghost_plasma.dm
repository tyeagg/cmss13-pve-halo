/obj/item/hardpoint/primary/ghost_plasma
	name = "\improper Bleihagel RE-RE700 Frontal Cannon"
	desc = "The marketing department over at Bleihagel would have you believe that the RE-RE700 is an original design. However, experts who pried the cover off the cannon have discovered an object with a striking similarity to the popular M56 Cupola. It is still unknown why the cannon has two barrels."
	icon = 'icons/obj/vehicles/hardpoints/apc.dmi'

	activation_sounds = list('sound/weapons/halo/gun_plasmarifle_1.ogg')
	activatable = FALSE

	health = 2000
	firing_arc = 120

	origins = list(0, -1)

	allowed_seat = VEHICLE_DRIVER

	ammo = new /obj/item/ammo_magazine/hardpoint/plasma
	max_clips = 5

	use_muzzle_flash = FALSE
	angle_muzzleflash = FALSE
	muzzleflash_icon_state = null

	muzzle_flash_pos = list(
		"1" = list(-14, 52),
		"2" = list(15, -82),
		"4" = list(68, -26),
		"8" = list(-68, -26)
	)

	scatter = 1
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(
		GUN_FIREMODE_AUTOMATIC,
	)
	fire_delay = 0.25 SECONDS
