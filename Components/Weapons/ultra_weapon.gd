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
			"contact_damage" : 40,
			"initial_speed" : 100,
			"bounces" : 1000,
			"acceleration" : 100
		}
	}

func fire(target : Vector2): #primary fire function
	if cooldown_timer.time_left != 0:
		return
	cooldown_timer.start(cooldown_time)
	for i in 1:
		arc_fire("basic",10,0.1,target)
		await get_tree().create_timer(0.1).timeout

