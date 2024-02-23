extends LabelAutosized

func _ready():
	GameDirector.player.weapon_swapped.connect(func():
		if GameDirector.player.weapons_list[GameDirector.player.cur_weapon_index]:
			text = GameDirector.player.weapons_list[GameDirector.player.cur_weapon_index].proper_name
		else:
			text = ""
	)
	GameDirector.player.weapons_update.connect(func():
		if GameDirector.player.weapons_list[GameDirector.player.cur_weapon_index]:
			text = GameDirector.player.weapons_list[GameDirector.player.cur_weapon_index].proper_name
		else:
			text = ""
	)
