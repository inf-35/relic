extends PanelContainer

class_name FancyPanel

@export var background : Control
@export var content : Control

@onready var background_tween : Tween
@onready var content_tween : Tween

@export var trigger_upon_index_change : bool = false
@export var trigger_upon_menu_change : bool = false

func _ready():
	GuiDirector.customisation_menu_activated.connect(trigger)
	GuiDirector.customisation_menu_changed.connect(trigger)
	GuiDirector.index_change.connect(trigger)
	self_modulate = Color(1,1,1,0)

# Called when the node enters the scene tree for the first time.
func trigger():
	if content:
		content.modulate = Color(1,1,1,0)
		if content_tween:
			content_tween.kill()
		
	if background and background is ProgressBar:
		if background_tween:
			background_tween.kill()
			
		background.value = background.min_value
		background_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		background_tween.tween_property(background,"value",background.max_value,0.3)
		background_tween.play()
	
	await get_tree().create_timer(0.3).timeout
		
	if content:
		content_tween = create_tween().set_trans(Tween.TRANS_QUAD)
		content_tween.tween_property(content,"modulate",Color(1,1,1,1),0.2).set_ease(Tween.EASE_OUT)
		content_tween.play()

