extends Controller

class_name HealthPickup

var health : float = 0
var age : float = 0

func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
		
	skin = "health_pickup"
	
	entity.get_node("HealthPickupPrompt").health = health
		
	entity.died.connect(func():
		queue_free()
	)
	
func _process(delta):
	age += delta
	
	if age > 8:
		queue_free()
	


