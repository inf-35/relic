extends Weapon

class_name BasicWeapon

func setup_stats():
	item_texture = preload("res://Interface Assets/basic.png")
	data_name = "basic_weapon"
	proper_name = "Pistol"
	description = "A [hint={hello}]basic[/hint] weapon"
	
	cooldown_time = 0.2
	projectile_types = {
		"basic" : {
			"contact_damage" : 40,
			"initial_speed" : 100
		}
	}
	
func fire(target : Vector2): #primary fire function
	if cooldown_timer.time_left != 0:
		return
		
	shot.emit()
	cooldown_timer.start(cooldown_time)
	single_fire("basic",target,{"med_freeze" = 0.5})
