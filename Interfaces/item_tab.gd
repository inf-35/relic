extends PanelContainer

class_name ItemTab


@export var weapon_slot : int = 1000
@export var module_slot : int = 1000
@export var item : Node:
	set(new_item):
		item = new_item
		update()

@onready var icon : TextureRect = get_node("HBoxContainer").get_node("IconMargin").get_node("AspectRatioFixed").get_node("Panel").get_node("MarginContainer").get_node("TextureRect")
@onready var stripe : Panel = get_node("HBoxContainer").get_node("Stripe")
@onready var info_margin : MarginContainer = get_node("HBoxContainer").get_node("InfoMargin")
@onready var title : Label = info_margin.get_node("VBoxContainer").get_node("Title")
@onready var info : Label = info_margin.get_node("VBoxContainer").get_node("Info")

signal customisation_exit

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	update()
		
	GameDirector.player.weapon_update.connect(func():
		update()
	)
	
	GameDirector.player.modules_update.connect(func():
		update()
	)
	
func update():
	if item and "proper_name" in item:
		icon.texture = item.item_texture
		title.text = item.proper_name
		info.text = item.description
	elif len(GameDirector.player.weapon_dict) > weapon_slot and GameDirector.player.weapon_dict[weapon_slot] is Weapon:
		icon.texture = GameDirector.player.weapon_dict[weapon_slot].item_texture
		title.text = GameDirector.player.weapon_dict[weapon_slot].proper_name
		info.text = GameDirector.player.weapon_dict[weapon_slot].description
	elif len(GameDirector.player.modules_list) > module_slot and GameDirector.player.modules_list[module_slot] is Module:	
		icon.texture = GameDirector.player.modules_list[module_slot].item_texture
		title.text = GameDirector.player.modules_list[module_slot].proper_name
		info.text = GameDirector.player.modules_list[module_slot].description
	else:
		icon.texture = preload("res://Interface Assets/null.png")
