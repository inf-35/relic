extends Weapon

class_name RoundWeapon

func setup_stats():
	item_texture = preload("res://Interface Assets/basic.png")
	data_name = "round_weapon"
	proper_name = "Round"
	description = "not intended for player use"
	
	cooldown_time = 1
	projectile_types = {
		"basic" : { #basic projectile used for most weapons
			"contact_damage" : [40,"hitbox"], #[value, scope]
			"initial_speed" : [10,"controller"],
			"status_effects" : [{},"hitbox"],
			"bounces" : [1,"controller"],
			"pierce" : [1, "controller"],
			"acceleration" : [100,"controller"],
			"affiliation" : ["controller","hitbox"],
			"parent_weapon" : [self,"controller"],
		}
	}

func fire_payload(target : Vector2):
	arc_fire(controller.entity.position,"basic",12,360,target)

