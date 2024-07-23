extends Node

class_name Weapon

signal shot #used when weapon is shot
signal child_projectile_landed #used when child projectile is destroyed, includes projectile node
signal cooldown_finished

var controller
var cooldown_timer = Timer.new()
var cooldown_time : float = 0.5
var lumen_cost : int = 0
var spawn_offset : float = 10 #distance bullets spawn (in direction of travel)
var camera_shake : float = 10.0
var projectile_types : Dictionary = {
	"basic" : {
		"contact_damage" : [{
				"normal" :0.0,
				"light" : 0.0,
				"fire" : 0.0,
				"kinetic" : 0.0,
				"blast" : 0.0,
				"poison" : 0.0
			},"hitbox"],
		"initial_speed" : 100,
		"affiliation" : "controller",
	}
}

var modified_projectile_types : Dictionary = projectile_types.duplicate(true)
var item_texture : Texture  #texture used for ui icon
var proper_name : String = "undefined" #TODO : implement localisation
var data_name : String = "undefined"
var description : String = "undefined"

var primary : bool = true
var secondaries : Array[Node] = []
var targeted_primary : Node: #targeted primary weapon (null if this weapon is not a modifier)
	set(new_primary):
		if targeted_primary:
			targeted_primary.disconnect("child_projectile_landed",on_child_projectile_landed)
			
		targeted_primary = new_primary
		if not targeted_primary:
			return
		
		targeted_primary.child_projectile_landed.connect(on_child_projectile_landed)

var enabled : bool = true #can this weapon function

func setup_stats():
	pass 

func _init():
	setup_stats()
	add_child(cooldown_timer)
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(func():
		cooldown_finished.emit()
	)

	child_projectile_landed.connect(on_child_projectile_landed)
	
func fire(target : Vector2) -> bool: 
	if cooldown_timer.time_left != 0:
		return false
		
	if not enabled:
		return false
	
	if "lumen" in controller and controller.lumen < lumen_cost:
		return false
	elif "lumen" in controller:
		controller.lumen -= lumen_cost
	
	var shake_vector : Vector2 = (controller.entity.global_position + target * 0.01 - GameDirector.camera.global_position)
	GameDirector.camera.shake_vector += shake_vector.normalized() * camera_shake / (1 + min(shake_vector.length() * 0.05, 10))
	fire_payload(target)
	shot.emit()
	cooldown_timer.start(cooldown_time)
	return true
	
func fire_payload(target : Vector2) -> void: #overriden by child class function
	push_warning(self, " does not have defined fire_payload function!")
	
func modify(primary : Node ) -> void: #takes in a primary[weapon] and modifies it in some fashion
	pass

func on_child_projectile_landed(recursion : int, position : Vector2, last_entity_hit):
	pass

func trigger_secondaries() -> void: #should be triggered with changes in secondary functionality
	modified_projectile_types = projectile_types.duplicate(true)
	for secondary in secondaries:
		secondary.modify(self)

func single_fire(position : Vector2, projectile_type : String, target : Vector2, origin = null) -> void:
	var projectile : Projectile = create_projectile(projectile_type,origin)
	projectile.property_cache.base_movement_speed = projectile.initial_speed
	projectile.property_cache.movement_vector = target.normalized()
	projectile.property_cache.position = position
	GameDirector.projectiles.add_child.call_deferred(projectile)
	
func arc_fire(position : Vector2, projectile_type : String, projectiles : int, angle : float = 360, target : Vector2 = Vector2.ONE, origin = null) -> void:
#function for firing multiple projectiles in an arc ; angle is the total angle of the arc
	for i in projectiles:
		var projectile : Projectile = create_projectile(projectile_type,origin)
		projectile.property_cache.base_movement_speed = projectile.initial_speed
		projectile.property_cache.position = position
		if int(angle) % 360 == 0: #prevents overlap between projectiles at 0/360 degrees
			projectile.property_cache.movement_vector = target.normalized().rotated(deg_to_rad(-angle * 0.5 + i * angle/(projectiles)))
		else:
			projectile.property_cache.movement_vector = target.normalized().rotated(deg_to_rad(-angle * 0.5 + i * angle/(projectiles-1)))
		GameDirector.projectiles.add_child.call_deferred(projectile)
			
func create_projectile(projectile_type : String, origin = null) -> Projectile:
	var projectile : Projectile = Projectile.new()
	if "velocity" in controller.entity: #inherits parent entity velocity
		projectile.property_cache.velocity = controller.entity.velocity
	
	for property in modified_projectile_types[projectile_type]:
		var value = modified_projectile_types[projectile_type][property][0]
		var scope : String = modified_projectile_types[projectile_type][property][1]
		
		projectile.parent_weapon = self
		if origin:
			projectile.hitbox_cache.origin = origin
		
		match property: #exceptions
			"affiliation" when value == "controller":
				projectile.affiliation = controller.affiliation #to the controller
				projectile.property_cache.affiliation = controller.affiliation #to the entity
				projectile.hitbox_cache.affiliation = controller.affiliation #to the hitbox
				continue
				
		match scope:
			null:
				projectile[property] = value
			"controller":
				projectile[property]= value
			"entity":
				projectile.property_cache[property] = value
			"hitbox":
				projectile.hitbox_cache[property] = value
				
	return projectile
	
	
