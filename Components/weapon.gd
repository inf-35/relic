extends Node

class_name Weapon

signal shot

var controller
var cooldown_timer = Timer.new()
var cooldown_time : float = 0.5

var basic_projectile : PackedScene = preload("res://Components/projectile.tscn")
var projectile_types : Dictionary = {
	"basic" : {
		"contact_damage" : 40,
		"initial_speed" : 100,
		"affiliation" : "player",
	}
}

var modified_projectile_types : Dictionary = projectile_types.duplicate(true)

var item_texture : Texture  #texture used for ui icon
var proper_name : String = "undefined" #TODO : implement localisation
var data_name : String = "undefined"
var description : String = "undefined"

var primary : bool = true
var secondaries : Array[Node] = []
var targeted_primary

func setup_stats():
	pass 

func _init():
	setup_stats()
	add_child(cooldown_timer)
	cooldown_timer.one_shot = true
	
func fire(target : Vector2) -> void: 
	if cooldown_timer.time_left != 0:
		return
		
	GameDirector.camera.shake_vector = -GameDirector.player.entity.get_local_mouse_position().normalized() * 2
	fire_payload(target)
	shot.emit()
	cooldown_timer.start(cooldown_time)
	
func fire_payload(target : Vector2) -> void: #overriden by child class function
	pass
	
func modify(primary : Node ) -> void: #takes in a primary[weapon] and modifies it in some fashion
	pass

func trigger_secondaries() -> void: #should be triggered with changes in secondary functionality
	modified_projectile_types = projectile_types.duplicate(true)
	for secondary in secondaries:
		secondary.modify(self)

func single_fire(projectile_type : String, target : Vector2) -> void:
	var projectile : Projectile = create_projectile(projectile_type)
	projectile.velocity = projectile.initial_speed * target.normalized()
	projectile.position = controller.entity.position
	GameDirector.projectiles.add_child.call_deferred(projectile)
	
func arc_fire(projectile_type : String, projectiles : int, angle : float = 360, target : Vector2 = Vector2.ONE) -> void:
#function for firing multiple projectiles in an arc ; angle is the total angle of the arc
	for i in projectiles:
		var projectile : Projectile = create_projectile(projectile_type)
		projectile.position = controller.entity.position
		if angle == 360:
			projectile.velocity = target.normalized().rotated(deg_to_rad(-angle * 0.5 + i * angle/(projectiles))) * projectile.initial_speed
		else:
			projectile.velocity = target.normalized().rotated(deg_to_rad(-angle * 0.5 + i * angle/(projectiles-1))) * projectile.initial_speed
		GameDirector.projectiles.add_child.call_deferred(projectile)	
			
func create_projectile(projectile_type : String) -> Projectile:
	var projectile : Projectile = basic_projectile.instantiate()
	projectile.affiliation = "player"
	for property in modified_projectile_types[projectile_type]:
		projectile[property] = modified_projectile_types[projectile_type][property]
	return projectile
	
	
