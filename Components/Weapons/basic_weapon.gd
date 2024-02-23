extends Weapon

class_name BasicWeapon

func _ready():
	item_texture = preload("res://Interface Assets/basic.png")
	proper_name = "Pistol"
	description = "A basic pistol."
	
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
	single_fire("basic",target)
