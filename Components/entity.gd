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

@export var base_max_hp : float:
	set(new_max_hp):
		base_max_hp = new_max_hp
		parse_modifiers()
@export var base_movement_speed : float:
	set(new_speed):
		base_movement_speed = new_speed
		parse_modifiers()
@export var skin : String

@export var lumen_drops : bool = true

@export_category("Resistances")
@export_range(0,1) var base_resistance : float:
	set(new_resistance):
		base_resistance = new_resistance
		parse_modifiers()
		
@export_range(0,1) var base_normal_resistance : float:
	set(new_normal_resistance):
		base_normal_resistance = new_normal_resistance
		parse_modifiers()
		
@export_range(0,1) var base_light_resistance : float:
	set(new_light_resistance):
		base_light_resistance = new_light_resistance
		parse_modifiers()
		
@export_range(0,1) var base_fire_resistance : float:
	set(new_fire_resistance):
		base_fire_resistance = new_fire_resistance
		parse_modifiers()

@export_range(0,1) var base_kinetic_resistance : float:
	set(new_kinetic_resistance):
		base_kinetic_resistance = new_kinetic_resistance
		parse_modifiers()

@export_range(0,1) var base_blast_resistance : float:
	set(new_blast_resistance):
		base_blast_resistance = new_blast_resistance
		parse_modifiers()
	
@export_range(0,1) var base_poison_resistance : float:
	set(new_poison_resistance):
		base_poison_resistance = new_poison_resistance
		parse_modifiers()
		

@onready var hp : float = base_max_hp:
	set(new_hp):
		if new_hp <= 0 and hp > 0:
			died.emit()
		if new_hp > stats.max_hp.final:
			hp = stats.max_hp.final
		else:
			if new_hp < hp and lumen_drops:
				var lumen_pickup : LumenPickup = LumenPickup.new()
				lumen_pickup.property_cache.position = position
				lumen_pickup.property_cache.velocity = Vector2(-100,-100)
				lumen_pickup.property_cache.friction = 5
				lumen_pickup.lumen = (hp - new_hp)
				GameDirector.projectiles.add_child.call_deferred(lumen_pickup)
				
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
	"resistance_boost" : {"level" : 0, "time" : 0.0},
	"max_hp_boost" : {"level" : 0, "time" : 0.0},
	"freeze" : {"level" : 0, "time" : 0.0},
	#setter status effects must be placed at the back
	"iframe" : {"level" : 0, "time" : 0.0}, #invincibilty frames for players after taking damage,
}

@export var movement_component : MovementComponent
@export var animation_player : AnimationPlayer
@export var main_hitbox : Area2D

var movement_vector : Vector2 = Vector2.ZERO
var motion : Vector2 = Vector2.ZERO #because velocity is somehow unable to track velocity
var last_position : Vector2 = Vector2.ZERO

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
	},
	"normal_resistance" : {
		"modified" : base_normal_resistance,
		"cache" : base_normal_resistance,
		"final" : base_normal_resistance,
		"signal" : resistance_changed,
	},
	"light_resistance" : {
		"modified" : base_light_resistance,
		"cache" : base_light_resistance,
		"final" : base_light_resistance,
		"signal" : resistance_changed,
	},
	"fire_resistance" : {
		"modified" : base_fire_resistance,
		"cache" : base_fire_resistance,
		"final" : base_fire_resistance,
		"signal" : resistance_changed,
	},
	"blast_resistance" : {
		"modified" : base_blast_resistance,
		"cache" : base_blast_resistance,
		"final" : base_blast_resistance,
		"signal" : resistance_changed,
	},
	"kinetic_resistance" : {
		"modified" : base_kinetic_resistance,
		"cache" : base_kinetic_resistance,
		"final" : base_kinetic_resistance,
		"signal" : resistance_changed,
	},
	"poison_resistance" : {
		"modified" : base_poison_resistance,
		"cache" : base_poison_resistance,
		"final" : base_poison_resistance,
		"signal" : resistance_changed,
	},
}
	
var speed_perc : float = 1 #should only be above 1 for sprinting / special charging attacks

var hit_cache : int = 0 #counts number of hits yet unprocessed
@export var mass : float = 2.0
var friction : float = 15.0

var projectile_intersection_area : Area2D

func reset_stats():
	hp = stats.max_hp.final
	speed_perc = 1
	parse_modifiers()
	
func hit(attacking_hitbox : Hitbox, attacked_hitbox : Hitbox):
	var attacking_status_effects : Dictionary = attacking_hitbox.status_effects
	var attacking_damages : Dictionary = attacking_hitbox.contact_damage
	var attacked_damage_mult : float = attacked_hitbox.damage_multiplier
	var attacking_motion : Vector2 = Vector2.ZERO
	var attacking_mass : float = 0.0
	var attacking_force : float = attacking_hitbox.force
	var attacking_position : Vector2 = attacking_hitbox.global_position
	if "velocity" in attacking_hitbox.entity:
		attacking_motion = attacking_hitbox.entity.motion
		attacking_mass = attacking_hitbox.entity.mass
		
	hit_cache += 1
	await get_tree().create_timer(0.02 * hit_cache).timeout #waits in the hit queue, 0.02s per unprocessed bullet
	hit_cache -= 1
	
	if status_effects.iframe.time > 0: #entity has an iframe (probably player)
		return
	
	for status_effect in attacking_status_effects:
		var time : float = attacking_status_effects[status_effect].time
		var level : float = attacking_status_effects[status_effect].level

		status_effects[status_effect].level += level
		status_effects[status_effect].time += time
		
	parse_stats()
	
	hp -= attacking_damages.normal * attacked_damage_mult * (1-stats.resistance.final) * (1-stats.normal_resistance.final) #normal damage 
	hp -= attacking_damages.light * attacked_damage_mult * (1-stats.resistance.final) * (1-stats.light_resistance.final) #light damage 
	hp -= attacking_damages.fire * attacked_damage_mult * (1-stats.resistance.final) * (1-stats.fire_resistance.final) #fire damage 
	hp -= attacking_damages.blast * attacked_damage_mult * (1-stats.resistance.final) * (1-stats.blast_resistance.final)
	hp -= attacking_damages.kinetic * attacked_damage_mult * (1-stats.resistance.final) * (1-stats.kinetic_resistance.final) #normal damage 
	hp -= attacking_damages.poison * attacked_damage_mult * (1-stats.resistance.final) * (1-stats.poison_resistance.final) #normal damage 
	
	entity_hit.emit()
	
	if attacking_motion.length() > 50:
		hp -= floor(attacking_motion.length() * attacking_mass / 500) * (1-stats.resistance.final) * (1-stats.kinetic_resistance.final) #kinetic damage
	parse_stats()
	
	if not "velocity" in self:
		return
		
	#knockback	
	if movement_component: self.velocity += (attacking_motion+(attacked_hitbox.global_position-attacking_position)*0.01).normalized() * attacking_force / mass
	
func animation_callback_func(identifier : String): #animation player calls this function
	animation_callback.emit(identifier)
	
func _ready():
	if controller is Projectile: #creates a duplicate area2d that allows us to cheaply detect projectile collisions with terrain
		projectile_intersection_area = Area2D.new()
		projectile_intersection_area.set_collision_mask_value(5,true) #with terrain
		projectile_intersection_area.set_collision_mask_value(1,false)
		projectile_intersection_area.set_collision_layer_value(1,false)
		for child in get_children(): #projectile_intersection_area has exactly the same shape as projectile hitbox
			if child is CollisionShape2D:
				var duplicate : CollisionShape2D = child.duplicate()
				projectile_intersection_area.add_child(duplicate)
		add_child(projectile_intersection_area)
		##
		#await get_tree().process_frame
		#await get_tree().process_frame	
		#print(projectile_intersection_area.get_overlapping_bodies())
		#
		#if (len(projectile_intersection_area.get_overlapping_bodies()) > 0):
			#queue_free()
		
		while is_instance_valid(self):
			last_position = global_position
			await get_tree().create_timer(0.1).timeout
			motion = (position - last_position) * 10
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parse_status_effects(delta)
	
var bounce_lock : bool = false

func _physics_process(delta):
	if not "velocity" in self:
		return
		
	if controller is Projectile:
		if not controller.assigned_pattern_number:
			self.velocity = movement_vector * stats.movement_speed.final * speed_perc * delta * 5
			position += self.velocity
		
		if controller.bouncy:
			var collide_result = move_and_collide(self.velocity,true)
			
			if collide_result and not bounce_lock:
				bounce_lock = true
				await get_tree().create_timer(delta*2).timeout
				movement_vector = movement_vector.bounce(collide_result.get_normal())
				await get_tree().create_timer(0.2).timeout
				bounce_lock = false
		else:
			var collide_result = move_and_collide(self.velocity,true)
		
			if collide_result and not bounce_lock:
				bounce_lock = true
				await get_tree().create_timer(delta * 2).timeout
				if not controller.proxy_only and not controller.invincible: 
					var sample : Vector2 = collide_result.get_position() + collide_result.get_travel() * 0.001
					var tile : Vector2i = Vector2i(floor(sample.x/20),floor(sample.y/20))
					GameDirector.damage_tile(tile,controller.hitbox.contact_damage.normal)
					queue_free()
				await get_tree().create_timer(0.2).timeout
				bounce_lock = false
	else:
		self.velocity += movement_vector * stats.movement_speed.final * speed_perc * delta * 200
		self.velocity *= (1 - friction * delta)
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
			
	parse_status_effects() #an update in modifiers necessitates an update in status effects
	parse_stats()
		
func parse_status_effects(delta : float = 0.016):
	for status_effect in status_effects:
		var time = status_effects[status_effect].time
		#status effects decay
		if time is float or time is int:
			if time <= 0:
				pass
			elif time <= delta:
				status_effects[status_effect].level = 0
				status_effects[status_effect].time = 0.0
				parse_stats()
			else:
				status_effects[status_effect].time -= delta
			
func parse_stats():
	for stat in stats:
		stats[stat].final = stats[stat].modified
		
	for status_effect in status_effects:
		var time : float = status_effects[status_effect].time
		var level : float = status_effects[status_effect].level
		match status_effect:
			"freeze" when time > 0:
				stats.movement_speed.final = stats.movement_speed.modified * 1/(level*0.5 + 1)
			"max_hp_boost" when time > 0:
				stats.max_hp.final = stats.max_hp.modified + level
			"resistance_boost" when time > 0:
				stats.resistance.final = stats.resistance.modified + level
			"iframe" when time > 0: #causes entities to ignore hits
				pass
