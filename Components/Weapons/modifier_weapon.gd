extends Weapon

class_name ModifierWeapon

func setup_stats():
	name = "Modifier"
	primary = false #is a modifier
	item_texture = preload("res://Interface Assets/ultra.png")
	proper_name = "Modifier"
	data_name = "modifier_weapon"
	description = "A less basic pistol."
	
	cooldown_time = 0.01
	projectile_types = {
	}

func modify(target : Node): #primary modifier function
	target.modified_projectile_types.basic.acceleration[0] = 0
