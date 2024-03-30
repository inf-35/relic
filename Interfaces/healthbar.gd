extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
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
	var tween : Tween = create_tween()
	tween.tween_property(self,"value",GameDirector.player.entity.hp,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.set_parallel().tween_property(self,"max_value",GameDirector.player.entity.stats.max_hp.final,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.play()
