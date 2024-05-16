extends Controller

class_name Projectile

var parent_weapon : Node
var velocity : Vector2 = Vector2.ZERO
var acceleration : float = 0.0

var contact_damage : float = 20
var initial_speed : float = 40

var bounces : int = 1:
	set(new_bounces):
		bounces = new_bounces
		if bounces <= 0:
			queue_free()
			
var pierce : int = 1:
	set(new_pierce):
		pierce = new_pierce
		if pierce <= 0:
			queue_free()
			
var lifetime : float = 10.0

var bullet_height : float = 10.0

var is_descendant : bool = false

var health : float = 100:
	set(new_health):
		health = new_health
		if health <= 0:
			queue_free()
			
var lifetime_timer : Timer
var age : float = 0

var level_raycast : RayCast2D = RayCast2D.new()

var hitbox : Hitbox
var hitbox_cache : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	skin = "projectile"
	
	hitbox = entity.main_hitbox
	hitbox.parent_projectile = self
	
	for property in hitbox_cache:
		if property in hitbox:
			hitbox[property] = hitbox_cache[property]
			
	hitbox.enabled = true
	
	add_child(level_raycast)
	
	lifetime_timer = Timer.new()
	add_child(lifetime_timer)
	lifetime_timer.one_shot = true
	lifetime_timer.start(lifetime)
	
	lifetime_timer.timeout.connect(func():
		entity.main_hitbox.monitorable = false
		entity.main_hitbox.monitoring = false
		queue_free()
	)
	
	level_raycast.set_collision_mask_value(1,false)
	await get_tree().create_timer(0.2).timeout
	level_raycast.set_collision_mask_value(5,true)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	age += delta
	
	level_raycast.position = entity.position + Vector2(0,bullet_height)
	level_raycast.target_position = (entity.movement_vector * entity.stats.movement_speed.final) * delta * 10
	level_raycast.force_update_transform()
	level_raycast.force_raycast_update()
	if level_raycast.is_colliding():
		bounces -= 1
		var normal = level_raycast.get_collision_normal()
		entity.movement_vector = entity.movement_vector.bounce(normal)
		
	if GameDirector.stasis:
		return
	
	entity.rotation = (entity.movement_vector).angle()
	entity.base_movement_speed += acceleration * delta
	
func _exit_tree():
	if is_instance_valid(parent_weapon):
		if not is_descendant:
			parent_weapon.child_projectile_landed.emit(entity.position)
		else:
			parent_weapon.descendant_projectile_landed.emit(entity.position)
			#
	#remove_child(entity)
	#if EntityAbstraction.skin_pools.has(skin):
		#EntityAbstraction.skin_pools[skin].append(entity)
