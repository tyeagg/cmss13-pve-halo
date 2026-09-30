/obj/item/ammo_magazine/hardpoint/plasma
	name = "M56 Cupola Magazine"
	desc = "A box of 1000, 10x28mm caseless rounds for the M56 heavy machine gun system."
	caliber = "10x28mm"
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/uscm.dmi'
	icon_state = "cupola_1"
	w_class = SIZE_LARGE
	default_ammo = /datum/ammo/energy/halo_plasma/plasma_rifle
	max_rounds = 1000
	gun_type = /obj/item/hardpoint/primary/ghost_plasma

/obj/item/ammo_magazine/hardpoint/plasma/update_icon()
	icon_state = "cupola_[current_rounds <= 0 ? "0" : "1"]"
