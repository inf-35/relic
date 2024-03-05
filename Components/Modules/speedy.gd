extends Module

class_name Speedy

func setup_stats():
	item_texture = preload("res://Interface Assets/basic.png")
	data_name = "basic_module"
	proper_name = "Speedy"
	description = "speeeeeeeeeeeeed"

# Called when the node enters the scene tree for the first time.
func activate():
	player.entity.modifiers.multiplicative_speed_boost = 1

func deactivate():
	player.entity.modifiers.multiplicative_speed_boost = 1
 
