extends Area2D

class_name Prompt

var just_activated : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	if not is_instance_valid(GameDirector.player): return
	
	GameDirector.player.action_signal.connect(func():
		just_activated = false
	)
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func on_area_entered(area : Area2D):
	if "entity" in area:
		area.entity.controller.actions_list.append(self)

func on_area_exited(area : Area2D):
	if "entity" in area:
		area.entity.controller.actions_list.erase(self)
	
func action(actor):
	push_error("action not defined for ", self)

