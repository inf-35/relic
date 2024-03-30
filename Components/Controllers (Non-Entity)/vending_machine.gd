extends Controller

class_name VendingMachine

# Called when the node enters the scene tree for the first time.
func _ready():
	skin = "vending_machine"

	entity.died.connect(func():
		queue_free()
	)
	


