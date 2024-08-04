extends Controller

class_name Projectile

var parent_weapon : Node
var velocity : Vector2 = Vector2.ZERO
var acceleration : float = 0.0

var contact_damage : float = 20
var initial_speed : float = 40

var bouncy : bool = true #ability to bounce (off terrain and such)
			
var pierce : int = 1: #number of pierces (through entities)
	set(new_pierce):
		pierce = new_pierce
		if pierce <= 0 and not proxy_only and not invincible:
			queue_free()
			
var lifetime : float = 10.0

var bullet_height : float = 10.0

var final_scale : Vector2
var expansion_time : float

var recursion : int = 0 #how many layers is this projectile removed from the original bullet

var locked : bool = false

var assigned_pattern_number : int
var proxy_only : bool = false #projectile is only the proxy for a pattern

var invincible : bool = false #projectile can only be killed by age

var lifetime_timer : Timer
var age : float = 0:
	set(new_age):
		age = new_age
		if age > lifetime and not proxy_only:
			queue_free()

var level_raycast : RayCast2D = RayCast2D.new()

var hitbox : Hitbox
var hitbox_cache : Dictionary

var last_entity_hit : Node #records the last entity hit

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	set_skin()
	
	hitbox = entity.main_hitbox
	hitbox.parent_projectile = self
	
	if proxy_only:
		entity.visible = false
		hitbox.enabled = false
		
	for property in hitbox_cache:
		if property in hitbox:
			hitbox[property] = hitbox_cache[property]
	
	for property in hitbox_cache:
		if property in hitbox:
			hitbox[property] = hitbox_cache[property]
			#
	#local_patterns = patterns.duplicate(true)
	#for pattern in local_patterns:
		#pattern["evolution"] = 0 #stores how much the pattern has evolved
		#pattern["evolution2"] = 0 #secondary evolution
		#pattern["start"] = numbers_taken
		#match pattern.shape:
			#"orbit":
				#for i in pattern.projectiles:
					#var projectile : Projectile = parent_weapon.create_projectile(pattern.composition)
					#projectile.property_cache.base_movement_speed = projectile.initial_speed
					#projectile.property_cache.position = entity.position + Vector2(0,pattern.length).rotated(deg_to_rad(i * 360/(pattern.projectiles)))
					#projectile.assigned_pattern_number = numbers_taken
					#child_projectiles[numbers_taken] = projectile
					#numbers_taken += 1
					#GameDirector.projectiles.add_child.call_deferred(projectile)
					#
	if final_scale:
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(entity,"scale",final_scale,expansion_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameDirector.stasis:
		return
		
	if not is_instance_valid(entity):
		return
	
	age += delta
	
	#projectiles_destroyed = 0
	#for pattern in local_patterns:
		#for i in range(pattern.start,pattern.start+pattern.projectiles):
			#if not is_instance_valid(child_projectiles[i]):
				#projectiles_destroyed += 1
				#continue
#
			#if child_projectiles.has(i) and is_instance_valid(child_projectiles[i].entity):
				#match pattern.shape:
					#"orbit":
						#child_projectiles[i].entity.position = entity.position + Vector2(0,pattern.length + pattern.evolution2).rotated(deg_to_rad((i-pattern.start) * 360/(pattern.projectiles) + pattern.evolution))
		#pattern.evolution += pattern.speed * delta
		#pattern.evolution2 += pattern.speed2 * delta
#
	#if projectiles_destroyed >= len(child_projectiles) and proxy_only: #all child projectiles destroyed (as proxy)
		#queue_free()
	
	if acceleration != 0:
		entity.base_movement_speed += acceleration * delta
	
func _exit_tree():
	if is_instance_valid(parent_weapon) and is_instance_valid(entity):
		parent_weapon.child_projectile_landed.emit(recursion,entity.position,last_entity_hit)
		
func set_skin():
	skin = "basic_projectile"
