extends TileMap

class_name InteractiveTileMap

@onready var nav_region : NavigationRegion2D = get_parent()
var cells_to_scenes : Dictionary = {
	
}

var cache : int = 0


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
	if local_cache == cache: #no updates in the past 1 second
		nav_region.bake_navigation_polygon(true)
	elif local_cache + 10 < cache:
		cache -= 10
		nav_region.bake_navigation_polygon(true)
		
		
func create_features(features : Dictionary):
	for feature_pos in features:
		var feature_scene = features[feature_pos]
		feature_scene.property_cache.position = feature_pos * 20
		if feature_scene is Controller:
			GameDirector.controllers.add_child.call_deferred(feature_scene)
		else:
			get_parent().add_child.call_deferred(feature_scene)
