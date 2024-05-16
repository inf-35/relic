extends Weapon

class_name UltraWeapon

func setup_stats():
	item_texture = preload("res://Interface Assets/ultra.png")
	proper_name = "Ultra"
	data_name = "ultra_weapon"
	description = "A less basic pistol."
	
	cooldown_time = 0.01
	projectile_types = {
		"basic" : {
			"contact_damage" : [40,"hitbox"],
			"initial_speed" : [10,"controller"],
			"status_effects" : [{"heavy_freeze" = 0.2},"hitbox"],
			"bounces" : [5,"controller"],
			"pierce" : [1, "controller"],
			"acceleration" : [1,"controller"],
			"affiliation" : ["neutral","hitbox"],
			"parent_weapon" : [self,"controller"],
			"is_descendant" : [false,"controller"],
		},
		"split" : {
			"contact_damage" : [40,"hitbox"],
			"initial_speed" : [40,"controller"],
			"lifetime" : [0.4,"controller"],
			"status_effects" : [{"heavy_freeze" = 0.2},"hitbox"],
			"bounces" : [1,"controller"],
			"pierce" : [1, "controller"],
			"acceleration" : [100,"controller"],
			"affiliation" : ["neutral","hitbox"],
			"parent_weapon" : [self,"controller"],
			"is_descendant" : [true,"controller"],
		},
	}

func fire_payload(target : Vector2): #primary fire function
	for i in 1:
		single_fire(controller.entity.position,"basic",target)
		await get_tree().create_timer(0.1).timeout
		
func on_child_projectile_landed(pos : Vector2):
	arc_fire(pos,"split",8)

