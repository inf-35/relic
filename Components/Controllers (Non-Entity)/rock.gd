extends Controller

class_name Rock

var state : String = "rock":
	set(new_state):
		match new_state:
			"rock":
				pass
		state = new_state
		
func _init():
	immobile = true
		
# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	skin = "rock"
	
	entity.died.connect(func():
		queue_free.call_deferred()
	)
	


