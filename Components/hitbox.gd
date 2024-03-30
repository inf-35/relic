extends Area2D

class_name Hitbox

signal action

@export var entity : Entity

@export var damage_multiplier : float = 1
@export var contact_damage : float = 20
@export var knockback : float = 0

var status_effects : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	area_entered.connect(on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func on_area_entered(area):
	if "contact_damage" in area:
		entity.hit(area,self)
		area.collide()		
				
func collide():
	pass

