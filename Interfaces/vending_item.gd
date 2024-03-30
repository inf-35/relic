extends VBoxContainer

class_name VendingItem

var item 

@export var emphasis_on_hover : bool
@export var shake_on_hover : bool

var shop
var mouse_over : bool


# Called when the node enters the scene tree for the first time.
func _ready():
	tree_exited.connect(func():
		item.queue_free()
	)
	
	if get_node_or_null("UiShake"):
		var tween1 : Tween
		var tween2 : Tween
		mouse_entered.connect(func():
			mouse_over = true
			if emphasis_on_hover:
				if tween2 and tween2.is_running() : tween2.pause()
				if tween1 : tween1.kill()
				tween1 = create_tween()
				tween1.tween_property(self,"scale",Vector2(1.05,1.05),0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
				tween1.play()
			if shake_on_hover:
				get_node("UiShake").looping = true
		)
		
		mouse_exited.connect(func():
			mouse_over = false
			if emphasis_on_hover:
				if tween1 and tween1.is_running() : tween1.pause()
				if tween2 : tween2.kill()
				tween2 = create_tween()
				tween2.tween_property(self,"scale",Vector2.ONE,0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
				tween2.play()
			if shake_on_hover:
				get_node("UiShake").looping = false
		)
	
	gui_input.connect(func(event):
		if Input.is_action_just_pressed("primary"):
			shop.selected_item = item
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
