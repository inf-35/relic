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
			"contact_damage" : [0,"hitbox"], #[value, scope]
			"initial_speed" : [40,"controller"],
			"status_effects" : [{},"hitbox"],
			"bounces" : [1,"controller"],
			"pierce" : [2, "controller"],
			"acceleration" : [0,"controller"],
			"affiliation" : ["controller","hitbox"],
			"parent_weapon" : [self,"controller"],
		}
	}
	
func fire_payload(target : Vector2): #primary fire function
	arc_fire(controller.entity.position,"basic",5,20,target)
