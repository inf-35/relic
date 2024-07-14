extends Controller

class_name LumenPickup

var lumen : float = 0
var age : float = 0

func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
		
	skin = "lumen_pickup"
	
	entity.get_node("LumenPickupPrompt").lumen = lumen
		
	entity.died.connect(func():
		queue_free()
	)
	
func _process(delta):
	age += delta
	
	if age > 8:
		queue_free()
	


