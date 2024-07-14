extends Controller

class_name Teleporter

var destination_level : int
var destination_world : String
var destination_level_type : String

func _init():
	immobile = true
# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	skin = "teleporter"
	
	entity.get_node("TeleportPrompt").destination_level = destination_level
	entity.get_node("TeleportPrompt").destination_world = destination_world
	entity.get_node("TeleportPrompt").destination_level_type = destination_level_type
	
	entity.died.connect(func():
		queue_free()
	)
	


