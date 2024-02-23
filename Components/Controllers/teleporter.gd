extends Controller

class_name Teleporter

# Called when the node enters the scene tree for the first time.
func _ready():
	skin = "teleporter"
	
	entity.died.connect(func():
		queue_free()
	)
	


