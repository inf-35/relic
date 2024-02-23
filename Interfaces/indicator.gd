extends PanelContainer

class_name Indicator

@export var weapon : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameDirector.player.cur_weapon_index == weapon:
		self_modulate = Color(1,1,1,1)
		modulate = Color(1,1,1,1)
	else:
		self_modulate = Color(1,1,1,0)
		modulate = Color(1,1,1,0.5)
		
	GameDirector.player.weapon_swapped.connect(func():
		if GameDirector.player.cur_weapon_index == weapon:
			self_modulate = Color(1,1,1,1)
			modulate = Color(1,1,1,1)
		else:
			self_modulate = Color(1,1,1,0)
			modulate = Color(1,1,1,0.5)
	)
