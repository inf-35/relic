extends Node

signal reset

@onready var world : Node2D = get_tree().get_root().get_node("World")
@onready var controllers : Node2D = get_tree().get_root().get_node("World").get_node("Controllers")
@onready var projectiles : Node2D = get_tree().get_root().get_node("World").get_node("Projectiles")
@onready var nav_region : NavigationRegion2D = world.get_node("NavigationRegion2D")
@onready var player : Player = get_tree().get_root().get_node("World").get_node("Controllers").get_node("Player")
@onready var ceilingmap : TileMap = nav_region.get_node("CeilingMap")
@onready var tilemap : TileMap = nav_region.get_node("TileMap")
@onready var background : Sprite2D = nav_region.get_node("Background")

var cell_size : int = 20
var floors_to_create : Array[Vector2i] = []
var walls_to_create : Array[Vector2i] = []
var ceilings_to_create : Array[Vector2i] = []
var features_to_create : Dictionary = {}
var enemy_spawns : Array[Dictionary] = [{"captures" : null, "position" : Vector2i.ZERO}]
signal stasis_set

var stasis : bool = false:
	set(new_stasis):
		PhysicsServer2D.set_active(true)
		stasis_set.emit(new_stasis)
		stasis = new_stasis
		
# Called when the node enters the scene tree for the first time.
func _ready():
	create_path(Vector2i(0,0),50,{Vector2.LEFT : 5, Vector2.RIGHT : 6, Vector2.UP : 5, Vector2.DOWN : 5})
	write_tiles()
	await get_tree().create_timer(0.1).timeout
	spawn_post_processing()
	write_enemies()
	tilemap.create_features(features_to_create)
	
func reset_scene(reset_controllers : bool):
	for layer in tilemap.get_layers_count():
		tilemap.clear_layer(layer)
		
	for layer in ceilingmap.get_layers_count():
		ceilingmap.clear_layer(layer)
		
	for child in nav_region.get_children():
		if (not child is TileMap) and not child == background:
			child.queue_free()
		
	if reset_controllers:
		for controller in controllers.get_children():
			if not controller is Player:
				controller.queue_free()
		
		for projectile in projectiles.get_children():
			projectile.queue_free()
				
	floors_to_create = []
	walls_to_create = []
	ceilings_to_create = []
	features_to_create = {}
	enemy_spawns = [{"captures" : null, "position" : Vector2i.ZERO}]
	create_path(Vector2i(0,0),50,{Vector2.LEFT : 5, Vector2.RIGHT : 6, Vector2.UP : 5, Vector2.DOWN : 5})
	write_tiles()
	await get_tree().create_timer(0.1).timeout
	spawn_post_processing()
	write_enemies()
	tilemap.create_features(features_to_create)
	
	player.entity.position = Vector2.ZERO + Vector2(cell_size,cell_size) * 0.5
		
	
func create_path(origin : Vector2i, limit : float, direction_weights : Dictionary):
	var position : Vector2i = Vector2.ZERO
	var weighted_directions : Array[Vector2i] = []
	for direction in direction_weights:
		for i in direction_weights[direction]:
			weighted_directions.append(Vector2i(direction))
			
	while (position - origin).length() < limit:
		position += weighted_directions.pick_random()
		if draw(position,Vector2(1,1)):
			if randf() > 0.5:
				draw(position,Vector2(2,2))
				enemy_spawns.append({"captures" : 0, "position" : position})
	
	features_to_create[position] = Teleporter
	
func write_tiles():
	for floor_tile in floors_to_create:
		var rock_noise : FastNoiseLite = FastNoiseLite.new()
		rock_noise.seed = randi()
		rock_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		if rock_noise.get_noise_2d(floor_tile.x*0.1,floor_tile.y*0.1) > 0.1:
			if not features_to_create.has(floor_tile):
				features_to_create[floor_tile] = Rock
			pass
		tilemap.set_cell(0,floor_tile,1,Vector2i.ZERO)
		
		var decor_noise : FastNoiseLite = FastNoiseLite.new()
		decor_noise.seed = randi()
		if decor_noise.get_noise_3d(floor_tile.x*0.2,floor_tile.y*0.2,0.2) > 0:
			tilemap.set_cell(2,floor_tile,1,Vector2i(0,1))
		if decor_noise.get_noise_3d(floor_tile.x*0.2,floor_tile.y*0.2,34.1) > 0.2:
			tilemap.set_cell(1,floor_tile,1,Vector2i(0,2))

	for wall_tile in walls_to_create:
		tilemap.set_cell(0,wall_tile,1,Vector2i(1,0))
		
	for ceiling_tile in ceilings_to_create:
		ceilingmap.set_cell(0,ceiling_tile,1,Vector2i(2,0))
		
	#setup nav-polygon
	var bounding_rect : Rect2i = tilemap.get_used_rect()
	var nav_polygon : NavigationPolygon = NavigationPolygon.new()
	nav_polygon.agent_radius = 4
	var bounding_outline : PackedVector2Array = PackedVector2Array([Vector2i(bounding_rect.position.x-10,bounding_rect.end.y+10)*cell_size,Vector2i(bounding_rect.end.x+10,bounding_rect.end.y+10)*cell_size,Vector2i(bounding_rect.end.x+10,bounding_rect.position.y-10)*cell_size,Vector2i(bounding_rect.position.x-10,bounding_rect.position.y-10)*cell_size])
	nav_polygon.add_outline(bounding_outline)
	nav_region.navigation_polygon = nav_polygon
	nav_region.bake_navigation_polygon(true)
	
func write_enemies():
	for spawn in enemy_spawns:
		if spawn.captures != null:
			var enemy : Controller
			if spawn.captures > 4:
				enemy = Beetle.new()
			else:
				enemy = Grunt.new()
			enemy.property_cache.position = spawn.position * cell_size + Vector2i(cell_size * 0.5,cell_size * 0.5)
			controllers.add_child(enemy)
		
func draw(start : Vector2i, size : Vector2i) -> bool:
	var overlap : int = 0
	for x in size.x:
		for y in size.y:
			var local_pos : Vector2i = Vector2i(start.x + x,start.y + y)
			if floors_to_create.has(local_pos):
				overlap += 1
			else:
				floors_to_create.append(local_pos)	
				if walls_to_create.has(local_pos):
					walls_to_create.erase(local_pos)
				if ceilings_to_create.has(local_pos):
					ceilings_to_create.erase(local_pos)
				var wall_adjacencies : Array[Vector2i] = [
					Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)]
				for adjacency in wall_adjacencies:
					if not walls_to_create.has(local_pos + adjacency) and not floors_to_create.has(local_pos + adjacency):
						walls_to_create.append(local_pos + adjacency)
						
				var ceiling_adjacencies : Array[Vector2i] = [
					Vector2(2,2),Vector2(2,1),Vector2(2,0),Vector2(2,-1),Vector2(2,-2),
					Vector2(1,2),Vector2(1,1),Vector2(1,0),Vector2(1,-1),Vector2(1,-2),
					Vector2(0,2),Vector2(0,1),Vector2(0,-1),Vector2(0,-2),
					Vector2(-2,2),Vector2(-2,1),Vector2(-2,0),Vector2(-2,-1),Vector2(-2,-2),
					Vector2(-1,2),Vector2(-1,1),Vector2(-1,0),Vector2(-1,-1),Vector2(-1,-2),]
				for adjacency in ceiling_adjacencies:
					if not ceilings_to_create.has(local_pos + adjacency) and not floors_to_create.has(local_pos + adjacency):
						ceilings_to_create.append(local_pos + adjacency)
				
	return overlap >= size.x * size.y
	
func spawn_post_processing():
	var raycast : RayCast2D = RayCast2D.new()
	raycast.set_collision_mask_value(5,true)
	nav_region.add_child(raycast)
					
	#proximity check
	var deleted_spawns : int = 0
	for enemy_spawn_index in len(enemy_spawns):
		if enemy_spawns[enemy_spawn_index - deleted_spawns].captures != null:
			var enemy_spawn = enemy_spawns[enemy_spawn_index - deleted_spawns]
			var check_depth : int = enemy_spawn.captures * 5 + 3
			for cur_check in check_depth:
				var check_spawn = enemy_spawns[enemy_spawn_index - cur_check - deleted_spawns - 1]
				if check_spawn.captures == null:
					break
				elif (check_spawn.position - enemy_spawn.position).length() < min((enemy_spawn.captures + check_spawn.captures) * 0.1,1) + 1.1:
					deleted_spawns += 1
					enemy_spawn.captures += check_spawn.captures + 1
					enemy_spawns.erase(check_spawn)
	#raycast check
	deleted_spawns = 0
	for enemy_spawn_index in len(enemy_spawns):
		if enemy_spawns[enemy_spawn_index - deleted_spawns].captures != null: 
			var enemy_spawn = enemy_spawns[enemy_spawn_index - deleted_spawns]
			var check_depth : int = 2
			for cur_check in check_depth:
				var check_spawn = enemy_spawns[enemy_spawn_index - cur_check - deleted_spawns - 1]
				if check_spawn.captures == null:
					break
				else:
					raycast.position = Vector2i(enemy_spawn.position * cell_size) + Vector2i(cell_size*0.5,cell_size*0.5)
					raycast.target_position = (check_spawn.position - enemy_spawn.position) * cell_size
					raycast.force_raycast_update()
					if not raycast.is_colliding():
						if randf() > 0.6:
							deleted_spawns += 1
							enemy_spawns.erase(check_spawn)
	raycast.queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
