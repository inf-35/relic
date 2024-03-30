extends PanelContainer

class_name ItemBox

@export var weapon_slot : int = 9999:
	set(new_slot):
		weapon_slot = new_slot
		update()
@export var module_slot : int = 9999:
	set(new_slot):
		module_slot = new_slot
		update()
@export var weapon : Weapon:
	set(new_weapon):
		weapon = new_weapon
		update()
@export var module : Module:
	set(new_module):
		module = new_module
		update()

@export var shake : bool
@export var shake_on_hover : bool
@export var emphasis_on_hover : bool = true

@onready var icon : TextureRect = get_node("IconMargin/HBoxContainer/AspectRatioFixed/Panel/MarginContainer/TextureRect")
@onready var stripe : Panel = get_node("IconMargin/HBoxContainer/Stripe")
@onready var info_container : VBoxContainer = get_node("IconMargin/HBoxContainer/VBoxContainer")
@onready var title : RichTextLabel = info_container.get_node("Title")
@onready var info : RichTextLabel = info_container.get_node("Info")

var occupied : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	if get_node_or_null("UiShake") and shake:
		get_node("UiShake").looping = true
	elif get_node_or_null("UiShake"):
		get_node("UiShake").looping = false
		
	GuiDirector.weapon_swap.connect(func(swapped_index):
		if weapon_slot == swapped_index or weapon_slot == 1000:
			if get_node_or_null("UiShake"):
				get_node("UiShake").start_shake()
	)
	
	GuiDirector.module_swap.connect(func(swapped_index):
		if module_slot == swapped_index or module_slot == 1000:
			if get_node_or_null("UiShake"):
				get_node("UiShake").start_shake()
	)
	
	if get_node_or_null("UiShake"):
		var tween1 : Tween
		var tween2 : Tween
		mouse_entered.connect(func():
			if emphasis_on_hover:
				if tween2 and tween2.is_running() : tween2.pause()
				if tween1 : tween1.kill()
				tween1 = create_tween()
				tween1.tween_property(self,"scale",Vector2(1.05,1.05),0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
				tween1.play()
			if shake_on_hover:
				get_node("UiShake").looping = true
		)
		
		mouse_exited.connect(func():
			if emphasis_on_hover:
				if tween1 and tween1.is_running() : tween1.pause()
				if tween2 : tween2.kill()
				tween2 = create_tween()
				tween2.tween_property(self,"scale",Vector2.ONE,0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
				tween2.play()
			if shake_on_hover:
				get_node("UiShake").looping = false
		)
	
	update()
	
	GameDirector.player.weapon_update.connect(update)
	GameDirector.player.module_update.connect(update)

func update():
	occupied = true
	modulate = Color(1,1,1,1)
	if weapon:
		icon.texture = weapon.item_texture
		title.text = weapon.proper_name
		info.text = weapon.description
	elif module:
		icon.texture = module.item_texture
		title.text = module.proper_name
		info.text = module.description
	elif not GameDirector.player:
		return
	elif GameDirector.player.weapon_dict.has(weapon_slot) and GameDirector.player.weapon_dict[weapon_slot] is Weapon:
		icon.texture = GameDirector.player.weapon_dict[weapon_slot].item_texture
		title.text = GameDirector.player.weapon_dict[weapon_slot].proper_name
		info.text = GameDirector.player.weapon_dict[weapon_slot].description
	elif GameDirector.player.module_dict.has(module_slot) and GameDirector.player.module_dict[module_slot] is Module:
		icon.texture = GameDirector.player.module_dict[module_slot].item_texture
		title.text = GameDirector.player.module_dict[module_slot].proper_name
		info.text = GameDirector.player.module_dict[module_slot].description
	else:
		occupied = false
		modulate = Color(1,1,1,0)
		icon.texture = preload("res://Interface Assets/null.png")
		title.text = ""
		info.text = ""
