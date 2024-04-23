extends TextureRect

class_name WeaponDisplay

@export var weapon : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	if GameDirector.player.weapon_dict.has(weapon) and GameDirector.player.weapon_dict[weapon]:
		texture = GameDirector.player.weapon_dict[weapon].item_texture
	else:
		texture = preload("res://Interface Assets/null.png")
		
	GameDirector.player.weapon_update.connect(func():
		if GameDirector.player.weapon_dict.has(weapon) and GameDirector.player.weapon_dict[weapon]:
			texture = GameDirector.player.weapon_dict[weapon].item_texture
		else:
			texture = preload("res://Interface Assets/null.png")
	)
