extends Weapon

class_name SheathWeapon

func setup_stats():
	item_texture = preload("res://Interface Assets/selector.png")
	data_name = "sheath_weapon"
	proper_name = "Sheath"
	description = "A [hint={hello}]basic[/hint] weapon"
	
	cooldown_time = 0.5
	projectile_types = {
		"basic" : { #basic projectile used for most weapons
			"contact_damage" : [{
				"normal" : 4.0,
				"light" : 0.0,
				"fire" : 0.0,
				"kinetic" : 0.0,
				"blast" : 0.0,
				"poison" : 0.0
			},"hitbox"], #[value, scope]
			"initial_speed" : [40,"controller"],
			"status_effects" : [{},"hitbox"],
			"bouncy" : [false,"controller"],
			"pierce" : [2, "controller"],
			"acceleration" : [0,"controller"],
			"affiliation" : ["controller","hitbox"],
		}
	}
	
func fire_payload(target : Vector2): #primary fire function
	arc_fire(controller.entity.position,"basic",20,360,target)
