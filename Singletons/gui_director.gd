extends Node

@onready var main_gui : Control = GameDirector.world.get_node("UI").get_node("MainGui")
@onready var overlay : Control = main_gui.get_node("Overlay")
@onready var customisation : Control = main_gui.get_node("Customisation")

var lockout : bool = false

signal customisation_menu_changed
signal customisation_menu_activated

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
			customisation.visible = true
			customisation_menu_activated.emit()
			var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			get_tree().paused = true
			tween.tween_property(customisation,"modulate",Color(1,1,1,1),0.15).finished.connect(func():
				lockout = false
			)
		else:
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
	await get_tree().create_timer(2).timeout
	customisation_menu_type = "module_swap"
