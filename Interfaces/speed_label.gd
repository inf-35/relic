extends LabelAutosized

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	update_font_size()
	get_viewport().size_changed.connect(update_font_size)
	
	text = str(GameDirector.player.entity.stats.movement_speed.modified)
	
	GameDirector.player.entity.movement_speed_changed.connect(func():
		text = str(GameDirector.player.entity.stats.movement_speed.modified)
	)
