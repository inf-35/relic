extends LabelAutosized

class_name HealthLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	update_hp()
	
	GameDirector.player.entity.max_hp_changed.connect(func():
		update_hp()
	)
	
	GameDirector.player.entity.hp_changed.connect(func():
		update_hp()
	)	
	
func update_hp():
	text = "[right]%s / %s" % [str(GameDirector.player.entity.hp),str(GameDirector.player.entity.stats.max_hp.final)]
	
	
