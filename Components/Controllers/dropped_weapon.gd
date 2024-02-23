extends Controller

class_name DroppedWeapon

# Called when the node enters the scene tree for the first time.
func _ready():
	skin = "dropped_weapon"
	
	entity.died.connect(func():
		queue_free()
	)
	


