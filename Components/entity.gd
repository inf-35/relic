extends PhysicsBody2D

class_name Entity #class for anything with a controller and a hp bar

signal died

signal max_hp_changed
signal movement_speed_changed
signal resistance_changed
signal hp_changed
signal entity_hit

signal animation_callback

var controller #typing this would cause a cyclic reference
var status_effects_hash : int

@export var immobile : bool = false

@export var base_max_hp : float:
	set(new_max_hp):
		base_max_hp = new_max_hp
		parse_modifiers()
@export var base_resistance : float:
	set(new_resistance):
		base_resistance = new_resistance
		parse_modifiers()
@export var base_movement_speed : float:
	set(new_speed):
		base_movement_speed = new_speed
		parse_modifiers()
@export var skin : String

@onready var hp : float = base_max_hp:
	set(new_hp):
		if new_hp <= 0 and hp > 0:
			died.emit()
		hp = new_hp
		hp_changed.emit()
		
var modifiers : Dictionary = { #permanent modifiers (from like passives and stuff)
	"additive_speed_boost" : 0,
	"multiplicative_speed_boost" : 1,
	"additive_max_hp_boost" : 0,
	"multiplicative_max_hp_boost" : 1,
	"additive_resistance_boost" : 0,
	"multiplicative_resistance_boost" : 1,
}

var status_effects : Dictionary = { #temporary modifiers
	"resistance_boost" : 0,
	"max_hp_boost" : 0,
	"light_freeze" : 0.0,
	"med_freeze" : 0.0,
	"heavy_freeze" : 0.0,
	#setter status effects must be placed at the back
	"iframe" : 0.0, #invincibilty frames for players after taking damage,
}

@export var movement_component : MovementComponent
@export var animation_player : AnimationPlayer
@export var main_hitbox : Area2D

var movement_vector : Vector2 = Vector2.ZERO

var stats : Dictionary = {
	"movement_speed" : {
		"modified" : base_movement_speed,
		"cache" : base_movement_speed,
		"final" : base_movement_speed,
		"signal" : movement_speed_changed
	},
	"max_hp" : {
		"modified" : base_max_hp,
		"cache" : base_max_hp,
		"final" : base_max_hp,
		"signal" : max_hp_changed
	},
	"resistance" : {
		"modified" : base_resistance,
		"cache" : base_resistance,
		"final" : base_resistance,
		"signal" : resistance_changed
	}
}
	
var speed_perc : float = 1 #should only be above 1 for sprinting / special charging attacks

var hit_cache : int = 0 #counts number of hits yet unprocessed

func reset_stats():
	hp = stats.max_hp.final
	speed_perc = 1
	parse_modifiers()
	
func hit(attacking_hitbox : Hitbox, attacked_hitbox : Hitbox):
	if status_effects.iframe > 0: #entities with iframe ignore hits
		return
		
	var attacking_status_effects : Dictionary = attacking_hitbox.status_effects
	var attacking_contact_damage : float = attacking_hitbox.contact_damage
	var attacked_damage_mult : float = attacked_hitbox.damage_multiplier
	hit_cache += 1
	await get_tree().create_timer(0.02 * hit_cache).timeout #waits in the hit queue, 0.02s per unprocessed bullet
	entity_hit.emit()
	for status_effect in attacking_status_effects:
		status_effects[status_effect] += attacking_status_effects[status_effect]
	hp -= attacking_contact_damage * attacked_damage_mult * (1-stats.resistance.final)
	hit_cache -= 1
	parse_stats()
	
func animation_callback_func(identifier : String): #animation player calls this function
	animation_callback.emit(identifier)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parse_status_effects(delta)
	
func _physics_process(delta):
	if not "velocity" in self:
		return
		
	if controller is Projectile:
		var collide_result : KinematicCollision2D = move_and_collide(movement_vector * stats.movement_speed.final * speed_perc * delta * 5,false)
		if collide_result:
			controller.bounces -= 1
			movement_vector = movement_vector.bounce(collide_result.get_normal())
			
	else:
		self.velocity += movement_vector * stats.movement_speed.final * speed_perc * delta * 50
		self.velocity *= (1 - 5 * delta)
		movement(self)
	
func movement(node : Node):
	return node.move_and_slide()
	
func parse_modifiers():
	#default values of stats
	for modifier in modifiers:
		var value = modifiers[modifier]
		match modifier:
			"additive_speed_boost":
				stats.movement_speed.modified = base_movement_speed + value
			"multiplicative_speed_boost":
				stats.movement_speed.modified *= value
			"additive_max_hp_boost":
				stats.max_hp.modified = base_max_hp + value
			"multiplicative_max_hp_boost":
				stats.max_hp.modified *= value
			"additive_resistance_boost":
				stats.resistance.modified = base_resistance + value
			"multiplicative_resistance__boost":
				stats.resistance.modified *= value
				
	for stat in stats:
		if stats[stat].modified != stats[stat].cache:
			stats[stat].signal.emit()
			stats[stat].cache = stats[stat].modified
			
	parse_status_effects() #an update in modifiers neccessitates an update in status effects
		
func parse_status_effects(delta : float = 0.016):
	for stat in stats:
		stats[stat].final = stats[stat].modified
	for status_effect in status_effects:
		var value = status_effects[status_effect]
		#status effects decay
		if value is float or value is int:
			if value == 0:
				pass
			elif value <= delta:
				status_effects[status_effect] = 0
				parse_stats()
			else:
				status_effects[status_effect] -= delta
			
func parse_stats():
	for status_effect in status_effects:
		var value = status_effects[status_effect]
		match status_effect:
			"light_freeze" when value > 0:
				stats.movement_speed.final = stats.movement_speed.modified * 0.75
			"med_freeze" when value > 0:
				stats.movement_speed.final = stats.movement_speed.modified * 0.5
			"heavy_freeze" when value > 0:
				stats.movement_speed.final = stats.movement_speed.modified * 0.2
			"max_hp_boost" when value > 0:
				stats.max_hp.final = stats.max_hp.modified + value
			"resistance_boost" when value > 0:
				stats.resistance.final = stats.resistance.modified + value
			"iframe" when value > 0: #causes entities to ignore hits
				pass
