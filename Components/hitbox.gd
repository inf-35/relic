extends Area2D

class_name Hitbox

signal action

@export var entity : Entity #entity hitbox
var parent_projectile : Projectile #projectile hitbox

var intersecting_areas : Array[Area2D]

@export var damage_multiplier : float = 1
@export var contact_damage : Dictionary = {
	"normal" : 0.0,
	"light" : 0.0,
	"fire" : 0.0,
	"kinetic" : 0.0,
	"blast" : 0.0,
	"poison" : 0.0,
}
@export var force : float = 400.0 #determines knockback magnitude

var enabled : bool = true
var continuous_hit : bool = false

@export var lockable : bool = true #can this hitbox be locked on by homing projs

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

var origin : Entity #origin node (exclude in collision procession)
var exited_origin : bool = false

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
	
	if is_instance_valid(origin):
		area_exited.connect(func(area):
			if "entity" in area and area.entity == origin:
				exited_origin = true
		)
	
	while is_instance_valid(self):
		await get_tree().create_timer(0.05).timeout
		if not continuous_hit:
			continue
		for area in intersecting_areas:
			if not is_instance_valid(area):
				continue
			
			if overlaps_area(area):
				if "contact_damage" in area:
					var attacking_is_projectile : bool = is_instance_valid(area.parent_projectile)
					var self_is_projectile : bool = is_instance_valid(parent_projectile)
					
					if is_instance_valid(parent_projectile): #is projectile
						pass
					else:
						entity.hit(area,self)
					if is_instance_valid(area.parent_projectile): #area is projectile
						pass
					else:
						area.entity.hit(self,area)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func on_area_entered(area):
	if is_instance_valid(parent_projectile) and "area_entered" in parent_projectile: #callback
		parent_projectile.area_entered(area)

	if not "affiliation" in area:
		return
		
	if area.collision_tag > collision_tag: #only one hitbox will process the collision
		return
	
	if area.affiliation == affiliation and affiliation != "neutral": #same affiliation - discard
		return
		
	if not (area.enabled and enabled): #at least one area is disabled - discard
		return
		
	if is_instance_valid(parent_projectile) and is_instance_valid(parent_projectile.parent_weapon):
		if parent_projectile.parent_weapon.controller == area.entity.controller and (parent_projectile.age < 0.2):
			return
		if is_instance_valid(area.parent_projectile) and is_instance_valid(area.parent_projectile.parent_weapon):
			if parent_projectile.parent_weapon.controller == area.parent_projectile.parent_weapon.controller and (parent_projectile.age < 0.2 or area.parent_projectile.age < 0.2):
				return

	if is_instance_valid(area.entity) and is_instance_valid(origin):
		if area.entity == origin and not exited_origin:
			return
			
	if is_instance_valid(entity) and is_instance_valid(area.origin):
		if entity == area.origin and not exited_origin:
			return
				
	#if is_instance_valid(origin):
		#print(origin)
		#if area.entity == origin and parent_projectile.age < 0.15:
			#return
			#
	#if is_instance_valid(area.origin):
		#print(area.origin)
		#if self.entity == area.origin and area.parent_projectile.age < 0.15:
			#return
		
	#if is_instance_valid(parent_projectile):
		#if parent_projectile.age < 0.02:
			#return
			#
	#if is_instance_valid(area.parent_projectile):
		#if area.parent_projectile.age < 0.02:
			#return
	
	#collision processing
	if "contact_damage" in area:
		intersecting_areas.append(area)
		var attacking_is_projectile : bool = is_instance_valid(area.parent_projectile)
		var self_is_projectile : bool = is_instance_valid(parent_projectile)
		
		if is_instance_valid(parent_projectile): #is projectile
			parent_projectile.last_entity_hit = area.entity
			parent_projectile.pierce -= 1
		else:
			entity.hit(area,self)
		if is_instance_valid(area.parent_projectile): #area is projectile
			area.parent_projectile.last_entity_hit = area.entity
			area.parent_projectile.pierce -= 1
		else:
			area.entity.hit(self,area)

func on_area_exited(area):
	intersecting_areas.erase(area)
			
func on_body_entered(body):
	if is_instance_valid(parent_projectile) and "body_entered" in parent_projectile:
		parent_projectile.body_entered(body)
			
func collide():
	pass

