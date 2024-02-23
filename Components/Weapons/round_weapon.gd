extends Weapon

class_name RoundWeapon

func _ready():
	cooldown_time = 1
	projectile_types = {
		"basic" : {
			"contact_damage" : 40,
			"initial_speed" : 30
		}
	}

func fire(target : Vector2): #primary fire function
	if cooldown_timer.time_left != 0:
		return
	
	shot.emit()
	cooldown_timer.start(cooldown_time)
	arc_fire("basic",12,360,target)

