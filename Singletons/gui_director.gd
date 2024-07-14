extends Node

var main_gui : Control
var overlay : Control
var customisation : Control

var module_dict_index : int = 0:
	set(weapon_new):
		module_dict_index = weapon_new
		index_change.emit()
var passive_dict_index : int = 0:
	set(passive_new):
		passive_dict_index = passive_new
		index_change.emit()

var lockout : bool = false

signal customisation_menu_changed #ie from submenus to each other
signal customisation_menu_activated #

signal weapon_swap
signal passive_swap
signal index_change

@export var customisation_menu_type : String = "weapon_swap": #"weapon_swap", "passive_swap", "shop"
	set(new_menu_type):
		customisation_menu_type = new_menu_type
		customisation_menu_changed.emit()
		
@export var customisation_menu_visible : bool = false:
	set(new_menu_visible):
		if lockout:
			return
		lockout = true
		customisation_menu_visible = new_menu_visible
		if customisation_menu_visible:
			InputDirector.context = "customisation"
			customisation.visible = true
			customisation_menu_activated.emit()
			var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			get_tree().paused = true
			tween.tween_property(customisation,"modulate",Color(1,1,1,1),0.15).finished.connect(func():
				lockout = false
			)
		else:
			InputDirector.context = "gameplay"
			if GameDirector.player.weapon_dict[1000] is Weapon: #drops weapon
				var dropped_weapon = DroppedWeapon.new()
				dropped_weapon.weapon_name = GameDirector.player.weapon_dict[1000].data_name
				dropped_weapon.property_cache.position = GameDirector.player.entity.position
				GameDirector.player.weapon_dict[1000].free()
				GameDirector.projectiles.add_child.call_deferred(dropped_weapon)
					
			GameDirector.player.weapon_dict[1000] = null
			var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			get_tree().paused = false
			tween.tween_property(customisation,"modulate",Color(1,1,1,0),0.15).finished.connect(func():
				lockout = false
				customisation.visible = false
			)
			
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if not GameDirector.run_active: await GameDirector.run_start

	main_gui = GameDirector.world.get_node("UI").get_node("MainGui")
	overlay = main_gui.get_node("Overlay")
	customisation = main_gui.get_node("Customisation")
	
	customisation.visible = false
	customisation.modulate = Color(1,1,1,0)

func swap_weapons():
	var store = GameDirector.player.weapon_dict[1000]
	var selected_weapon 
	if GameDirector.player.weapon_dict.has(module_dict_index):
		selected_weapon = GameDirector.player.weapon_dict[module_dict_index]
	else:
		selected_weapon = null
		
	GameDirector.player.weapon_dict[1000] = selected_weapon
	GameDirector.player.weapon_dict[module_dict_index] = store
	weapon_swap.emit(module_dict_index)
	
func swap_passives():
	var store = GameDirector.player.passive_dict[1000]
	var selected_passive
	if GameDirector.player.passive_dict.has(passive_dict_index):
		selected_passive = GameDirector.player.passive_dict[passive_dict_index]
	else:
		selected_passive = null
	GameDirector.player.passive_dict[1000] = selected_passive
	GameDirector.player.passive_dict[passive_dict_index] = store
	passive_swap.emit(passive_dict_index)
