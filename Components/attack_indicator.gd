extends Node2D

class_name AttackIndicator

var indicators : Array = []
var color : Color
var primary_color : Color = Color.RED
var secondary_color : Color = Color.WHITE
var period : float = 1

var shape : String = "rect"
var arc_angle : float = 110
var radius : float = 20

var size : Vector2 = Vector2(40,40)

func _ready():
	z_as_relative = false
	z_index = 1000
	scale = Vector2.ZERO
	
	color = primary_color
	var initial_tween : Tween = create_tween()
	initial_tween.tween_property(self,"scale",Vector2.ONE,0.2)
	initial_tween.play()
	
	var tween : Tween = create_tween()
	tween.tween_property(self,"color",secondary_color,period*0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,"color",primary_color,period*0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()
	tween.play()
	
func close():
	var closing_tween : Tween = create_tween()
	closing_tween.tween_property(self,"scale",Vector2.ZERO,0.2)
	closing_tween.play()
	closing_tween.tween_callback(func():
		queue_free()
	)
	
func _draw():
	match shape:
		"arc":
			draw_arc(Vector2.ZERO,20,-deg_to_rad(arc_angle*0.5),deg_to_rad(arc_angle*0.5),ceil(arc_angle*0.05),color,1.0)
		"rect":
			var half_vert = size.y * 0.5
			var half_hor = size.x * 0.5
			draw_line(Vector2(-half_vert,-half_hor),Vector2(half_vert,-half_hor),color,1.0)
			draw_line(Vector2(half_vert,-half_hor),Vector2(half_vert,half_hor),color,1.0)
			draw_line(Vector2(half_vert,half_hor),Vector2(-half_vert,half_hor),color,1.0)
			draw_line(Vector2(-half_vert,half_hor),Vector2(-half_vert,-half_hor),color,1.0)
