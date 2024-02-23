extends PanelContainer

class_name WeaponCustomisation


@export var weapon_slot : int = 0
@export var weapon : Weapon

@onready var weapon_icon : TextureRect = get_node("HBoxContainer").get_node("IconMargin").get_node("AspectRatioFixed").get_node("Panel").get_node("MarginContainer").get_node("TextureRect")
@onready var stripe : Panel = get_node("HBoxContainer").get_node("Stripe")
@onready var info_margin : MarginContainer = get_node("HBoxContainer").get_node("InfoMargin")
@onready var title : Label = info_margin.get_node("VBoxContainer").get_node("Title")
@onready var info : Label = info_margin.get_node("VBoxContainer").get_node("Info")

# Called when the node enters the scene tree for the first time.
func _ready():
	if weapon:
		weapon_icon.texture = weapon.item_texture
		title.text = weapon.proper_name
		info.text = weapon.description
	elif GameDirector.player.weapons_list[weapon_slot] is Weapon:
		weapon_icon.texture = GameDirector.player.weapons_list[weapon_slot].item_texture
		title.text = GameDirector.player.weapons_list[weapon_slot].proper_name
		info.text = GameDirector.player.weapons_list[weapon_slot].description
	else:
		weapon_icon.texture = preload("res://Interface Assets/null.png")
	GameDirector.player.weapons_update.connect(func():
		if weapon:
			weapon_icon.texture = weapon.item_texture
			title.text = weapon.proper_name
			info.text = weapon.description
		elif GameDirector.player.weapons_list[weapon_slot] is Weapon:
			weapon_icon.texture = GameDirector.player.weapons_list[weapon_slot].item_texture
			title.text = GameDirector.player.weapons_list[weapon_slot].proper_name
			info.text = GameDirector.player.weapons_list[weapon_slot].description
		else:
			weapon_icon.texture = preload("res://Interface Assets/null.png")
	)
