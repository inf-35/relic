extends PhysicsBody2D

class_name Entity #class for anything with a controller and a hp bar

signal died

signal max_hp_changed
signal movement_speed_changed
signal resistance_changed
signal hp_changed

signal animation_callback

var controller #typing this would cause a cyclic reference

@export var immobile : bool = false

@export var base_max_hp : float
@export var base_resistance : float
@export var base_movement_speed : float #base movement speed
@export var mass : float

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
	"iframe" : false, #invincibilty frames for players after taking damage,
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
	
func hit(attacking_hitbox : Area2D, attacked_hitbox : Hitbox):
	var clone_attacking_hitbox : Area2D = attacking_hitbox.duplicate()
	var attacking_status_effects = attacking_hitbox.status_effects
	hit_cache += 1
	await get_tree().create_timer(0.02 * hit_cache).timeout
	for status_effect in attacking_status_effects:
		status_effects[status_effect] += attacking_status_effects[status_effect]
	hp -= clone_attacking_hitbox.contact_damage * attacked_hitbox.damage_multiplier * (1-stats.resistance.final)
	hit_cache -= 1
	clone_attacking_hitbox.queue_free()
	
func animation_callback_func(identifier : String): #animation player calls this function
	animation_callback.emit(identifier)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parse_modifiers(delta)
	parse_status_effects(delta)
	
func _physics_process(delta : float):
	if immobile or not movement_component:
		return
	movement_component.movement(self,movement_vector,stats.movement_speed.final,speed_perc,delta)
	movement_component.friction(self,1 - 0.3 * 60 * delta)

func parse_modifiers(delta : float):
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
		
func parse_status_effects(delta : float):
	for stat in stats:
		stats[stat].final = stats[stat].modified
		
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
			"iframe" when value:
				stats.resistance.final = 1
		#status effects decay
		if value is float or value is int:
			status_effects[status_effect] = max(status_effects[status_effect] - delta,0)
