extends Weapon

class_name UltraWeapon

func setup_stats():
	item_texture = preload("res://Interface Assets/ultra.png")
	proper_name = "Grenade"
	data_name = "ultra_weapon"
	description = "A less basic pistol."
	
	cooldown_time = 1
	lumen_cost = 2
	projectile_types = {
		"basic" : {
			"contact_damage" : [4,"hitbox"],
			"initial_speed" : [10,"controller"],
			"lifetime" : [1.5, "controller"],
			"status_effects" : [{"heavy_freeze" = 0.2},"hitbox"],
			"bouncy" : [true,"controller"],
			"pierce" : [1, "controller"],
			"acceleration" : [0,"controller"],
			"affiliation" : ["neutral","hitbox"],
			"parent_weapon" : [self,"controller"],
			"is_descendant" : [false,"controller"],
			"scale" : [Vector2(2,2),"entity"]
		},
		"split" : {
			"contact_damage" : [4,"hitbox"],
			"initial_speed" : [10,"controller"],
			"lifetime" : [2,"controller"],
			"status_effects" : [{"heavy_freeze" = 0.2},"hitbox"],
			"bouncy" : [false,"controller"],
			"pierce" : [1, "controller"],
			"acceleration" : [0,"controller"],
			"affiliation" : ["neutral","hitbox"],
			"parent_weapon" : [self,"controller"],
			"is_descendant" : [true,"controller"],
		},
	}

func fire_payload(target : Vector2): #primary fire function
	for i in 1:
		single_fire(controller.entity.position+target.normalized() * 6,"basic",target)
		await get_tree().create_timer(0.1).timeout
		
func on_child_projectile_landed(pos : Vector2):
	for i in 20:
		single_fire(pos,"split",Vector2.from_angle(randf_range(0,2*PI)))

