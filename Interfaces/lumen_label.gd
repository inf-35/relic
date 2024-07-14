extends LabelAutosized

class_name LumenLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	update_lumen()
	
	GameDirector.player.lumen_changed.connect(func():
		update_lumen()
	)
	
	setup()	
	
func update_lumen():
	text = "%s / %s" % [str(GameDirector.player.lumen),str(GameDirector.player.max_lumen)]
	
	
