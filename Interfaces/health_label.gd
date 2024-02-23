extends LabelAutosized

# Called when the node enters the scene tree for the first time.
func _ready():
	update_font_size()
	get_viewport().size_changed.connect(update_font_size)
	
	text = "%s/%s" % [str(GameDirector.player.entity.hp),str(GameDirector.player.entity.stats.max_hp.final)]
	GameDirector.player.entity.max_hp_changed.connect(func():
		update_hp()
	)
	
	GameDirector.player.entity.hp_changed.connect(func():
		update_hp()
	)	
	
func update_hp():
	text = "%s/%s" % [str(GameDirector.player.entity.hp),str(GameDirector.player.entity.stats.max_hp.final)]
	
	
