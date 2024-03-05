extends Node

@onready var main_gui : Control = GameDirector.world.get_node("UI").get_node("MainGui")
@onready var overlay : Control = main_gui.get_node("Overlay")
@onready var customisation : Control = main_gui.get_node("Customisation")
@onready var visibility_manager : VisibilityManager = customisation.get_node("Panel/HBoxContainer/Centre")

var lockout : bool = false

signal customisation_menu_changed
signal customisation_menu_activated

signal weapon_swap
signal module_swap

@export var customisation_menu_type : String = "standard": #"standard", "weapon_swap", "module_swap"
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
			print("On gameplay entered:")
			print(GameDirector.player.weapon_dict)
			if GameDirector.player.weapon_dict[1000] is Weapon: #drops weapon
				var dropped_weapon = DroppedWeapon.new()
				dropped_weapon.weapon_name = GameDirector.player.weapon_dict[1000].data_name
				dropped_weapon.property_cache.position = GameDirector.player.entity.position
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
	customisation.visible = false
	customisation.modulate = Color(1,1,1,0)

func swap_weapons():
	var store = GameDirector.player.weapon_dict[1000]
	GameDirector.player.weapon_dict[1000] = GameDirector.player.weapon_dict[visibility_manager.weapon_upgrades.index]
	GameDirector.player.weapon_dict[visibility_manager.weapon_upgrades.index] = store
	weapon_swap.emit(visibility_manager.weapon_upgrades.index)
	
func swap_modules():
	var store = GameDirector.player.module_dict[1000]
	GameDirector.player.module_dict[1000] = GameDirector.player.module_dict[visibility_manager.module_upgrades.index]
	GameDirector.player.module_dict[visibility_manager.module_upgrades.index] = store
	module_swap.emit(visibility_manager.module_upgrades.index)
