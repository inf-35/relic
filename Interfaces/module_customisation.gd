extends PanelContainer

class_name ModuleCustomisation


@export var module_slot : int = 0
@export var module : Module

@onready var module_icon : TextureRect = get_node("HBoxContainer").get_node("IconMargin").get_node("AspectRatioFixed").get_node("Panel").get_node("MarginContainer").get_node("TextureRect")
@onready var stripe : Panel = get_node("HBoxContainer").get_node("Stripe")
@onready var info_margin : MarginContainer = get_node("HBoxContainer").get_node("InfoMargin")
@onready var title : Label = info_margin.get_node("VBoxContainer").get_node("Title")
@onready var info : Label = info_margin.get_node("VBoxContainer").get_node("Info")

# Called when the node enters the scene tree for the first time.
func _ready():
	if module:
		module_icon.texture = module.item_texture
		title.text = module.proper_name
		info.text = module.description
	elif GameDirector.player.modules_list[module_slot] is Module:
		module_icon.texture = GameDirector.player.modules_list[module_slot].item_texture
		title.text = GameDirector.player.modules_list[module_slot].proper_name
		info.text = GameDirector.player.modules_list[module_slot].description
	else:
		module_icon.texture = preload("res://Interface Assets/null.png")
	GameDirector.player.modules_update.connect(func():
		if module:
			module_icon.texture = module.item_texture
			title.text = module.proper_name
			info.text = module.description
		elif GameDirector.player.modules_list[module_slot] is Module:
			module_icon.texture = GameDirector.player.modules_list[module_slot].item_texture
			title.text = GameDirector.player.modules_list[module_slot].proper_name
			info.text = GameDirector.player.modules_list[module_slot].description
		else:
			module_icon.texture = preload("res://Interface Assets/null.png")
	)
