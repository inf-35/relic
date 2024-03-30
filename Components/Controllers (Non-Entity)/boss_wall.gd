extends Controller

class_name BossWall

#wall that drops upon gamedirector boss_killed signal

var state : String = "active":
	set(new_state):
		match new_state:
			"active":
				pass
		state = new_state
		
# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	skin = "boss_wall"
	
	GameDirector.boss_killed.connect(func():
		entity.get_node("LevelCollision").disabled = true
		entity.get_node("Hitbox").get_node("HitboxCollision").disabled = true
	)
	
	entity.died.connect(func():
		queue_free.call_deferred()
	)
	


