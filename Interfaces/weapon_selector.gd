extends VBoxContainer

class_name WeaponIndicator

@export var weapon_slot : int = 0

@onready var cooldown_label : RichTextLabel = get_node("RichTextLabel")

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	GameDirector.player.weapon_update.connect(update)
	GameDirector.player.weapon_swapped.connect(update)
	
func _process(_delta):
	weapon_timer_update()

func weapon_timer_update():
	if not is_instance_valid(GameDirector.player):
		return
	if len(GameDirector.player.active_weapons_array) <= weapon_slot:
		cooldown_label.text = ""
		return
		
	if GameDirector.player.active_weapons_array[weapon_slot].cooldown_timer.time_left == 0:
		cooldown_label.text = "[center]RDY"
	else:
		cooldown_label.text = "[center]" + str(round(GameDirector.player.active_weapons_array[weapon_slot].cooldown_timer.time_left * 100) * 0.01)
		
func update():
	if len(GameDirector.player.active_weapons_array) <= weapon_slot:
		modulate = Color(1,1,1,0)
		return
	
	if GameDirector.player.active_weapons_array[weapon_slot] == null:
		modulate = Color(1,1,1,0)
		return
		
	if GameDirector.player.cur_weapon_index == weapon_slot:
		pivot_offset = size * 0.5
		var tween : Tween = create_tween()
		tween.tween_property(self,"modulate",Color(1,1,1,1),0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.set_parallel().tween_property(self,"scale",Vector2(1.2,1.2),0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.play()
	else:
		pivot_offset = size * 0.5
		var tween : Tween = create_tween()
		tween.tween_property(self,"modulate",Color(1,1,1,0.5),0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.set_parallel().tween_property(self,"scale",Vector2(1,1),0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.play()
	
	get_node("AspectRatio/PanelContainer/TextureRect").texture = GameDirector.player.active_weapons_array[weapon_slot].item_texture
	
