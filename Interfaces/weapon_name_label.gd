extends LabelAutosized

func _ready():
	GameDirector.player.weapon_swapped.connect(func():
		if GameDirector.player.weapon_dict[GameDirector.player.cur_weapon_index]:
			text = GameDirector.player.weapon_dict[GameDirector.player.cur_weapon_index].proper_name
		else:
			text = ""
	)
	GameDirector.player.weapon_update.connect(func():
		if GameDirector.player.weapon_dict[GameDirector.player.cur_weapon_index]:
			text = GameDirector.player.weapon_dict[GameDirector.player.cur_weapon_index].proper_name
		else:
			text = ""
	)
