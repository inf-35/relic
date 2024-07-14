extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	max_value = GameDirector.player.max_lumen
	value = GameDirector.player.lumen
	
	GameDirector.player.max_lumen_changed.connect(func():
		update_hp_bar()
	)
	
	GameDirector.player.lumen_changed.connect(func():
		update_hp_bar()
	)	
	
func update_hp_bar():
	max_value = GameDirector.player.max_lumen
	var tween : Tween = create_tween()
	tween.tween_property(self,"value",GameDirector.player.lumen,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.set_parallel().tween_property(self,"max_value",GameDirector.player.max_lumen,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.play()
