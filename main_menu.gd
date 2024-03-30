extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request("world.tscn")
	await get_tree().create_timer(2).timeout
	var world : Node = ResourceLoader.load_threaded_get("world.tscn").instantiate()
	
	world.ready.connect(func():
		GameDirector.start_run()
	)
	
	get_tree().root.add_child(world)
	get_tree().root.remove_child(self)
