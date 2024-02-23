extends Node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event : InputEvent):
	if Input.is_action_just_pressed("primary"):
		if len(GameDirector.player.weapons_list) > GameDirector.player.cur_weapon_index:
			if GameDirector.player.weapons_list[GameDirector.player.cur_weapon_index] is Weapon:
				GameDirector.player.weapons_list[GameDirector.player.cur_weapon_index].fire(GameDirector.player.entity.get_local_mouse_position())
	if Input.is_action_just_pressed("toggle"):
		GameDirector.player.cur_weapon_index = (GameDirector.player.cur_weapon_index + 1) % GameDirector.player.max_weapons
	if Input.is_action_just_pressed("interact"):
		if len(GameDirector.player.actions_list) <= 0:
			return
		if is_instance_valid(GameDirector.player.actions_list[0]):
			GameDirector.player.actions_list[0].action(GameDirector.player)
	if Input.is_action_just_pressed("ability"):
		GameDirector.stasis = true
		get_tree().create_timer(1).timeout.connect(func():
			GameDirector.stasis = false
		)

	if event.is_action_pressed("menu"):
		GuiDirector.customisation_menu_visible = not GuiDirector.customisation_menu_visible


func _process(_delta): #wasd handler
	if GuiDirector.customisation_menu_visible:
		return
	GameDirector.player.entity.movement_vector = Input.get_vector("left","right","up","down")
