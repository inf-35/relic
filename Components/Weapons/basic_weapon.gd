extends Weapon

class_name BasicWeapon

func setup_stats():
	item_texture = preload("res://Interface Assets/selector.png")
	data_name = "basic_weapon"
	proper_name = "Pistol"
	description = "A [hint={hello}]basic[/hint] weapon"
	
	cooldown_time = 0.5
	projectile_types = {
		"basic" : { #basic projectile used for most weapons
			"contact_damage" : [40,"hitbox"], #[value, scope]
			"initial_speed" : [30,"controller"],
			"status_effects" : [{},"hitbox"],
			"bounces" : [1,"controller"],
			"pierce" : [1, "controller"],
			"acceleration" : [0,"controller"],
			"affiliation" : ["controller","hitbox"],
			"parent_weapon" : [self,"controller"],
		}
	}
	
func fire_payload(target : Vector2): #primary fire function
	single_fire(controller.entity.position,"basic",target)
