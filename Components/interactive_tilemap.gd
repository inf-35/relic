extends TileMap

class_name InteractiveTileMap

@onready var nav_region : NavigationRegion2D = get_parent()
var cells_to_scenes : Dictionary = {
	
}

var cache : int = 0
var time_to_spawn : float = 0.2
var baking : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	get_parent().child_entered_tree.connect(func(_area):
		update_nav()
	)
	get_parent().child_exiting_tree.connect(func(_area):
		update_nav()
	)
	changed.connect(func():
		update_nav()
	)
	
func update_nav():
	cache += 1
	var local_cache = cache
	await get_tree().create_timer(1).timeout
	if local_cache == cache and not baking: #no updates in the past 1 second
		nav_region.bake_navigation_polygon(true)
		baking = true
		await nav_region.bake_finished
		await get_tree().create_timer(0.2).timeout
		baking = false
		
		
func create_features(features : Dictionary):
	for feature_pos in features:
		var feature_scene = features[feature_pos]
		feature_scene.property_cache.position = feature_pos * 20
		if feature_scene is Controller and not feature_scene.immobile:
			GameDirector.controllers.add_child.call_deferred(feature_scene)
		else:
			get_parent().add_child.call_deferred(feature_scene)
		await get_tree().create_timer(time_to_spawn/len(features)).timeout
