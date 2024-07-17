extends Weapon

class_name GruntWeapon

func setup_stats():
	item_texture = preload("res://Interface Assets/selector.png")
	data_name = "basic_weapon"
	proper_name = "Pistol"
	description = "A [hint={hello}]basic[/hint] weapon"
	
	cooldown_time = 0.5
	projectile_types = {
		"basic" : { #basic projectile used for most weapons
			"contact_damage" : [4,"hitbox"], #[value, scope]
			"initial_speed" : [12,"controller"],
			"status_effects" : [{},"hitbox"],
			"bouncy" : [false,"controller"],
			"pierce" : [1, "controller"],
			"acceleration" : [0,"controller"],
			"affiliation" : ["controller","hitbox"],
		}
	}
	
func fire_payload(target : Vector2): #primary fire function
	single_fire(controller.entity.position,"basic",target)
