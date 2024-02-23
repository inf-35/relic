extends Area2D

class_name Hitbox

signal action

@export var entity : Entity

@export var damage_multiplier : float = 1
@export var contact_damage : float = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	area_entered.connect(on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func on_area_entered(area):
	if "contact_damage" in area:
		entity.hit(area,self)
		area.collide() #deletes projectiles
				
func collide():
	pass

