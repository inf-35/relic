extends Area2D
class_name HomingModule

@export var detection_range : float
@export var detection_impact : float
@export var detection_area : Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if not (get_parent() and get_parent() is Projectile):
		return
		
	var parent_projectile : Projectile = get_parent()
	
	detection_area.get_child(0).shape.radius = detection_range
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
