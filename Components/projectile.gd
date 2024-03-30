extends Area2D

class_name Projectile

var controller
var velocity : Vector2 = Vector2.ZERO

var contact_damage : float = 20
var initial_speed : float = 40
var neutral : bool = false

var bounces : int = 0
var lifetime : float = 10.0

var lifetime_timer : Timer
var status_effects : Dictionary

@onready var corona : Sprite2D = get_node("Corona")
@onready var core : Sprite2D = get_node("Core")

var corona_spin : float = randf_range(0.5,2)
var core_spin : float = randf_range(0.5,2)

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	if neutral:
		set_collision_layer_value(1,false) #player to false
		set_collision_layer_value(2,false) #enemy to false
		set_collision_layer_value(4,true) #neutral to true
		
	lifetime_timer = Timer.new()
	add_child(lifetime_timer)
	lifetime_timer.one_shot = true
	lifetime_timer.start(lifetime)
	
	lifetime_timer.timeout.connect(func():
		monitorable = false
		monitoring = false
		var closing_tween = create_tween()
		closing_tween.tween_property(self,"scale",Vector2(0,0),0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		closing_tween.play()
		closing_tween.tween_callback(func():
			queue_free()
		)
	)
	
	var looping_core_tween = create_tween()
	looping_core_tween.tween_property(core,"scale",Vector2(0.01,0.01),0.25)
	looping_core_tween.tween_property(core,"scale",Vector2(0.04,0.04),0.25)
	looping_core_tween.set_ease(Tween.EASE_IN_OUT)
	looping_core_tween.set_loops()
	looping_core_tween.play()
	
	var looping_corona_tween = create_tween()
	looping_corona_tween.tween_property(corona,"scale",Vector2(0.05,0.05),0.2)
	looping_corona_tween.tween_property(corona,"scale",Vector2(0.06,0.06),0.2)
	looping_corona_tween.set_ease(Tween.EASE_IN_OUT)
	looping_corona_tween.set_loops()
	looping_corona_tween.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if GameDirector.stasis:
		return
	
	rotation = velocity.angle()
	position += velocity * delta

func _on_body_entered(body):
	if body is TileMap:
		queue_free()

func _on_area_exited(area):
	pass
	
func collide():
	queue_free()
