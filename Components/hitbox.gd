extends Area2D

class_name Hitbox

signal action

@export var entity : Entity #entity hitbox
var parent_projectile : Projectile #projectile hitbox

@export var damage_multiplier : float = 1
@export var contact_damage : float = 20

var enabled : bool = true

@export_enum("neutral","player","enemy") var affiliation : String:
	set(new_affiliation):
		affiliation = new_affiliation
		
		set_collision_mask_value(1,true)
		set_collision_mask_value(2,true)
		set_collision_mask_value(4,true)
		match affiliation:
			"neutral":
				set_collision_layer_value(1,false) #player to false
				set_collision_layer_value(2,false) #enemy to false
				set_collision_layer_value(4,true) #neutral to true
			"player":
				set_collision_layer_value(1,true) #player to false
				set_collision_layer_value(2,false) #enemy to false
				set_collision_layer_value(4,false) #neutral to true
			"enemy":
				set_collision_layer_value(1,false) #player to false
				set_collision_layer_value(2,true) #enemy to false
				set_collision_layer_value(4,false) #neutral to true

var status_effects : Dictionary = {}

var collision_tag : int

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	HitboxManager.hitbox_counter += 1
	collision_tag = HitboxManager.hitbox_counter
	
	match affiliation:
		"neutral":
			set_collision_layer_value(1,false) #player to false
			set_collision_layer_value(2,false) #enemy to false
			set_collision_layer_value(4,true) #neutral to true
		"player":
			set_collision_layer_value(1,true) #player to false
			set_collision_layer_value(2,false) #enemy to false
			set_collision_layer_value(4,false) #neutral to true
		"enemy":
			set_collision_layer_value(1,false) #player to false
			set_collision_layer_value(2,true) #enemy to false
			set_collision_layer_value(4,false) #neutral to true
	
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	area_entered.connect(on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func on_area_entered(area):
	if is_instance_valid(parent_projectile) and "area_entered" in parent_projectile: #callback
		parent_projectile.area_entered(area)

	if not area is Hitbox:
		return
	
	if area.affiliation == affiliation: #same affiliation - discard
		return
		
	if not (area.enabled and enabled): #at least one area is disabled - discard
		return
		
	if is_instance_valid(parent_projectile):
		if parent_projectile.age < 0.05:
			return
			
	if is_instance_valid(area.parent_projectile):
		if area.parent_projectile.age < 0.05:
			return
		
	if area.collision_tag > collision_tag: #only one hitbox will process the collision
		return
	
	if "contact_damage" in area:
		var attacking_is_projectile : bool = is_instance_valid(area.parent_projectile)
		var self_is_projectile : bool = is_instance_valid(parent_projectile)
		
		entity.hit(area,self)
		area.entity.hit(self,area)
			
		if is_instance_valid(parent_projectile): #is projectile
			parent_projectile.pierce -= 1
		if is_instance_valid(area.parent_projectile):
			area.parent_projectile.pierce -= 1
			
func on_body_entered(body):
	if is_instance_valid(parent_projectile) and "body_entered" in parent_projectile:
		parent_projectile.body_entered(body)
			
func collide():
	pass

