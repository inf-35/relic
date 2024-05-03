extends Weapon

class_name RoundWeapon

func setup_stats():
	cooldown_time = 1
	projectile_types = {
		"basic" : {
			"contact_damage" : 40,
			"initial_speed" : 30
		}
	}

func fire_payload(target : Vector2):
	arc_fire("basic",12,360,target)

