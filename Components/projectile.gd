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
var age : float = 0:
	set(new_age):
		age = new_age
		if age > lifetime:
			queue_free()

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
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameDirector.stasis:
		return
	
	age += delta

	#entity.get_node("Physical").rotation = (entity.movement_vector).angle()
	if acceleration != 0:
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
