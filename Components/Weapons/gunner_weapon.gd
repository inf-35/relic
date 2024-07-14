extends Weapon

class_name GunnerWeapon

func setup_stats():
	item_texture = preload("res://Interface Assets/selector.png")
	data_name = "gunner_weapon"
	proper_name = "Gunner"
	description = "A rapid pulse weapon used by cultist troops."
	
	cooldown_time = 0.02
	projectile_types = {
		"basic" : { #basic projectile used for most weapons
			"contact_damage" : [4,"hitbox"], #[value, scope]
			"initial_speed" : [12,"controller"],
			"status_effects" : [{},"hitbox"],
			"bouncy" : [false,"controller"],
			"pierce" : [1, "controller"],
			"acceleration" : [0,"controller"],
			"affiliation" : ["controller","hitbox"],
			"parent_weapon" : [self,"controller"],
		}
	}
	
func fire_payload(target : Vector2): #primary fire function
	single_fire(controller.entity.position,"basic",target)
