extends Node2D
class_name HomingModule

@export var detection_range : float
@export var detection_impact : float
@export var detection_area : Area2D

@onready var parent_proj_entity : Entity

var intersecting_areas : Array[Area2D]

# Called when the node enters the scene tree for the first time.
func _ready():
	if not (get_parent() and "controller" in get_parent() and get_parent().controller is Projectile):
		return
		
	parent_proj_entity = get_parent()
	
	match parent_proj_entity.controller.affiliation:
		"player":
			detection_area.set_collision_mask_value(2,true)
		"enemy":
			detection_area.set_collision_mask_value(1,true)
		"neutral":
			detection_area.set_collision_mask_value(1,true)
			detection_area.set_collision_mask_value(2,true)
			
	detection_area.get_child(0).shape.radius = detection_range
	
	detection_area.area_entered.connect(func(area):
		if "lockable" in area and area.lockable:
			intersecting_areas.append(area)
	)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var areas_to_delete : Array[Area2D]
	var distances : Array[float]
	var vectors : Array[Vector2]
	var total_distance : float = 0.0000001
	
	for area in intersecting_areas:
		if not is_instance_valid(area):
			continue
			
		if detection_area.overlaps_area(area):
			var vector = (parent_proj_entity.global_position - area.global_position)
			vectors.append(vector.normalized())
			distances.append(vector.length_squared())
		else:
			areas_to_delete.append(area)
			
	for area in areas_to_delete:
		intersecting_areas.erase(area)
			
	for distance in distances:
		total_distance += 1/distance
	
	for vector_key in len(vectors):
		var target : Vector2 = (parent_proj_entity.movement_vector - vectors[vector_key]).normalized()
		parent_proj_entity.movement_vector = (parent_proj_entity.movement_vector + target * (detection_impact * delta * distances[vector_key] / total_distance)).normalized()
	
	
