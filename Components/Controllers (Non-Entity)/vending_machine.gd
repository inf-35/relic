extends Controller

class_name VendingMachine

func _init():
	immobile = true
# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	skin = "vending_machine"
	
	entity.died.connect(func():
		queue_free()
	)
	


