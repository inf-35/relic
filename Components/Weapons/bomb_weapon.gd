extends Weapon

class_name BombWeapon

func setup_stats():
	item_texture = preload("res://Interface Assets/basic.png")
	data_name = "bomb_weapon"
	proper_name = "Bomb"
	description = "not intended for player use"
	
	cooldown_time = 1
	projectile_types = {
		"basic" : { #basic projectile used for most weapons
			"contact_damage" : [4,"hitbox"], #[value, scope]
			"initial_speed" : [0,"controller"],
			"status_effects" : [{},"hitbox"],
			"lifetime" : [2.0,"controller"],
			"bouncy" : [false,"controller"],
			"pierce" : [1, "controller"],
			"invincible" : [true, "controller"],
			"acceleration" : [0,"controller"],
			"affiliation" : ["neutral","hitbox"],
			"scale" : [Vector2(0.8,0.8),"entity"],
			"final_scale" : [Vector2(20,20),"controller"],
			"expansion_time" : [0.8,"controller"],
			"parent_weapon" : [self,"controller"],
		}
	}

func fire_payload(target : Vector2):
	single_fire(controller.entity.position,"basic",target)

