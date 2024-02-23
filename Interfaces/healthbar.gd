extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = GameDirector.player.entity.stats.max_hp.final
	value = GameDirector.player.entity.hp
	
	GameDirector.player.entity.max_hp_changed.connect(func():
		update_hp_bar()
	)
	
	GameDirector.player.entity.hp_changed.connect(func():
		update_hp_bar()
	)	
	
func update_hp_bar():
	max_value = GameDirector.player.entity.stats.max_hp.final
	value = GameDirector.player.entity.hp
