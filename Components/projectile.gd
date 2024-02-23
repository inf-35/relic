extends Area2D

class_name Projectile

var controller
var velocity : Vector2 = Vector2.ZERO

var contact_damage : float = 20
var initial_speed : float = 40
var neutral : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if neutral:
		set_collision_layer_value(1,false) #player to false
		set_collision_layer_value(2,false) #enemy to false
		set_collision_layer_value(4,true) #neutral to true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if GameDirector.stasis:
		return
		
	position += velocity * delta

func _on_body_entered(body):
	if body is TileMap:
		queue_free()

func _on_area_exited(area):
	pass
	
func collide():
	queue_free()
