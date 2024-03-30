extends Node

class_name UiShake

@export var stretch : float = 1
@export var twist : float
@export var time : float
@export var looping_stretch : float = 1
@export var looping_twist : float
@export var looping_time : float

@export var looping : bool:
	set(n_looping):
		looping = n_looping
	
		if looping:
			looping_tween = create_tween()
			
			looping_tween.tween_property(parent,"rotation",deg_to_rad(looping_twist),looping_time*0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			looping_tween.parallel().tween_property(parent,"scale",Vector2(looping_stretch,looping_stretch),looping_time*0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			looping_tween.tween_property(parent,"rotation",deg_to_rad(-looping_twist),looping_time*0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			looping_tween.parallel().tween_property(parent,"scale",Vector2.ONE,looping_time*0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			looping_tween.tween_property(parent,"rotation",0,looping_time*0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			looping_tween.set_loops()
			looping_tween.play()
			
		elif looping_tween and looping_tween.is_running():
			looping_tween.kill()
			parent.rotation = 0
			parent.scale = Vector2(1,1)
		

var is_shaking : bool = false

var tween : Tween
var looping_tween : Tween

var parent : Control

func _ready():
	parent = get_parent()
	
	if looping_time != 0:
		looping = true

	
func start_shake(l_shake = null, l_twist = null, l_time = null):
	
	tween = create_tween()
	
		
	if looping_tween and looping_tween.is_running():
		looping_tween.stop()
		
	if tween.is_running():
		tween.stop()

	#tween.tween_property(parent,"global_position",shake,time*0.1).as_relative().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(parent,"rotation",deg_to_rad(twist),time*0.1).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(parent,"scale",Vector2(stretch,stretch),time*0.1).set_trans(Tween.TRANS_LINEAR)
	#tween.tween_property(parent,"global_position",-shake,time*0.9).as_relative().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(parent,"rotation",0,time*0.9).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(parent,"scale",Vector2.ONE,time*0.9).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(func():
		if looping_tween and looping_tween.is_valid():
			looping_tween.play()
	)

	tween.play()

