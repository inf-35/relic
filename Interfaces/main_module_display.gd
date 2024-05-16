extends Control

class_name MainModuleDisplay

@export var module_slot : int = 0

@onready var display_box : VBoxContainer = get_node("Display/MarginContainer/Display")
@onready var empty_status : RichTextLabel = get_node("Display/MarginContainer/Status")
@onready var weapon_display : TextureRect = display_box.get_node("AspectRatioContainer/TextureRect")
@onready var title : RichTextLabel  = display_box.get_node("Title")
@onready var subheader : RichTextLabel = display_box.get_node("Subheader")
@onready var description : RichTextLabel = display_box.get_node("Description")
@onready var end : RichTextLabel = display_box.get_node("End")

@onready var stack : Control = get_node("Stack")

@onready var dependencies : Control = get_node("Dependencies")
@onready var dependencies_container : Control = get_node("Dependencies/MarginContainer/VBoxContainer")

var dependency_controls : Array[Control] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	GuiDirector.index_change.connect(func():
		module_slot = GuiDirector.module_dict_index
		update()
	)
	
	GameDirector.player.weapon_update.connect(update)
	scale = Vector2(0.5,1)

func update():
	if GameDirector.player.weapon_dict.has(module_slot) and GameDirector.player.weapon_dict[module_slot] is Weapon:
		display_box.visible = true
		empty_status.visible = false
		var module : Weapon = GameDirector.player.weapon_dict[module_slot]
		title.text = module.proper_name
		weapon_display.texture = module.item_texture
		description.text = module.description
		
		end.text = "module display :: " + module.data_name
		
		if len(module.secondaries) > 0:
			dependencies.modulate = Color(1,1,1,1)
		else:
			dependencies.modulate = Color(1,1,1,0)
			
		for panel in dependency_controls:
			if is_instance_valid(panel):
				panel.queue_free()
		
		for secondary in module.secondaries:
			var secondary_panel : Control = preload("res://Interfaces/aspect_ratio_weapon_display.tscn").instantiate()
			dependencies_container.add_child(secondary_panel)
			dependency_controls.append(secondary_panel)
	else:
		display_box.visible = false
		empty_status.visible = true
			
		
	for i in len(stack.get_children()):
		var panel : Panel = stack.get_children()[i]
		if i == module_slot:
			panel.self_modulate = Color(1,1,1,1)
		else:
			panel.self_modulate = Color(0.141,0.141,0.141,1)

