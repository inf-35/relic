extends Node

var context : String = "gameplay" #gameplay, customisation

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event : InputEvent):
	match context:
		"gameplay":
			if Input.is_action_just_pressed("primary"):
				if len(GameDirector.player.weapon_dict) > GameDirector.player.cur_weapon_index:
					if GameDirector.player.weapon_dict[GameDirector.player.cur_weapon_index] is Weapon:
						GameDirector.player.weapon_dict[GameDirector.player.cur_weapon_index].fire(GameDirector.player.entity.get_local_mouse_position())
						
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

			if Input.is_action_just_pressed("menu"):
				GuiDirector.customisation_menu_type = "standard"
				GuiDirector.customisation_menu_visible = true
				
			GameDirector.player.entity.movement_vector = Input.get_vector("left","right","up","down")
		"customisation":
			if Input.is_action_just_pressed("menu"):
				GuiDirector.customisation_menu_visible = false
				
			match GuiDirector.customisation_menu_type:
				"standard":
					pass
				"weapon_swap":
					if Input.is_action_just_pressed("interact"):
						GuiDirector.swap_weapons()
						
				"module_swap":
					if Input.is_action_just_pressed("interact"):
						GuiDirector.swap_modules()
		"settings":
			pass
