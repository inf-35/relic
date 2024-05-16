extends Node

var context : String = "gameplay" #gameplay, customisation

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(_delta):
	if not GameDirector.run_active:
		return
	
	if not is_instance_valid(GameDirector.player):
		return
		
	GameDirector.player.entity.movement_vector = Input.get_vector("left","right","up","down")

func _input(event : InputEvent):
	if not GameDirector.run_active:
		return
	
	if not is_instance_valid(GameDirector.player):
		return
		
	match context:
		"gameplay":
			if Input.is_action_just_pressed("primary"):
				if len(GameDirector.player.active_weapons_array) > GameDirector.player.cur_weapon_index:
					if GameDirector.player.active_weapons_array[GameDirector.player.cur_weapon_index] is Weapon:
						GameDirector.player.active_weapons_array[GameDirector.player.cur_weapon_index].fire(GameDirector.player.entity.get_local_mouse_position())
						GameDirector.player.cur_weapon_index = (GameDirector.player.cur_weapon_index + 1) % (len(GameDirector.player.active_weapons_array))
			
			if Input.is_action_just_pressed("interact"):
				if len(GameDirector.player.actions_list) <= 0:
					return
				var selected_prompt : Prompt
				var index : int = 0
				
				while true: #alternates between stacked prompts
					if is_instance_valid(GameDirector.player.actions_list[index]):
						if not GameDirector.player.actions_list[index].just_activated:
							selected_prompt = GameDirector.player.actions_list[index]
							break
						
						if len(GameDirector.player.actions_list)-1 < (index+1):
							selected_prompt = GameDirector.player.actions_list[index]
							break
							
						else:
							index += 1
							
				GameDirector.player.action_signal.emit()
				
				if selected_prompt:
					selected_prompt.action(GameDirector.player)
					selected_prompt.just_activated = true
					
			if Input.is_action_just_pressed("ability"):
				GameDirector.stasis = true
				get_tree().create_timer(1).timeout.connect(func():
					GameDirector.stasis = false
				)

			if Input.is_action_just_pressed("menu"):
				GuiDirector.customisation_menu_type = "weapon_swap"
				GuiDirector.customisation_menu_visible = true
			
		"customisation":
			if Input.is_action_just_pressed("menu"):
				GuiDirector.customisation_menu_visible = false
				
			match GuiDirector.customisation_menu_type:
				"weapon_swap":
					if Input.is_action_just_pressed("up"):
						GuiDirector.module_dict_index += 1
					if Input.is_action_just_pressed("down"):
						GuiDirector.module_dict_index -= 1
					if Input.is_action_just_pressed("interact"):
						GuiDirector.swap_weapons()
				
				
				"passive_swap":
					if Input.is_action_just_pressed("interact"):
						GuiDirector.swap_passives()
		"settings":
			pass
