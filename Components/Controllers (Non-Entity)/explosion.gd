extends Controller

class_name Explosion

var state : String = "exploding":
	set(new_state):
		match new_state:
			"exploding":
				pass
		state = new_state

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	skin = "explosion"
	
	entity.died.connect(func():
		queue_free.call_deferred()
	)
	


