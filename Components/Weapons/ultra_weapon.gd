extends Weapon

class_name UltraWeapon

func setup_stats():
	item_texture = preload("res://Interface Assets/ultra.png")
	proper_name = "Ultra"
	data_name = "basic_weapon"
	description = "A less basic pistol."
	
	cooldown_time = 0.01
	projectile_types = {
		"basic" : {
			"contact_damage" : 40,
			"initial_speed" : 100
		}
	}

func fire(target : Vector2): #primary fire function
	if cooldown_timer.time_left != 0:
		return
	cooldown_timer.start(cooldown_time)
	for i in 2:
		arc_fire("basic",5,40,target)
		await get_tree().create_timer(0.1).timeout

