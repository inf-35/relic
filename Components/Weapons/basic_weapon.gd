extends Weapon

class_name BasicWeapon

func setup_stats():
	item_texture = preload("res://Interface Assets/basic.png")
	data_name = "basic_weapon"
	proper_name = "Pistol"
	description = "A [hint={hello}]basic[/hint] weapon"
	
	cooldown_time = 0.2
	projectile_types = {
		"basic" : { #basic projectile used for most weapons
			"contact_damage" : 40,
			"initial_speed" : 0.1,
			"status_effects" : {"heavy_freeze" = 0.5},
			"bounces" : 1000,
			"acceleration" : 100,
		}
	}
	projectile_types.make_read_only()
	
func fire(target : Vector2): #primary fire function
	if cooldown_timer.time_left != 0:
		return
		
	GameDirector.camera.shake_vector = -GameDirector.player.entity.get_local_mouse_position().normalized() * 2
	shot.emit()
	cooldown_timer.start(cooldown_time)
	single_fire("basic",target)
