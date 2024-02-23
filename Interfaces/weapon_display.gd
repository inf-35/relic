extends TextureRect

class_name WeaponDisplay

@export var weapon : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameDirector.player.weapons_list[weapon] is Weapon:
		texture = GameDirector.player.weapons_list[weapon].item_texture
	else:
		texture = preload("res://Interface Assets/null.png")
		
	GameDirector.player.weapons_update.connect(func():
		if GameDirector.player.weapons_list[weapon] is Weapon:
			texture = GameDirector.player.weapons_list[weapon].item_texture
		else:
			texture = preload("res://Interface Assets/null.png")
	)
