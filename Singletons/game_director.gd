extends Node

signal reset

var world : Node2D
var camera : Camera
var controllers : Node2D
var projectiles : Node2D
var nav_region : NavigationRegion2D
var player : Player
var ceilingmap : TileMap
var tilemap : InteractiveTileMap
var roommap : TileMap
var background : Sprite2D

var cell_size : int = 20
var floors_to_create : Dictionary = {} #contains coords of floor tiles to be created
var walls_to_create : Dictionary = {}
var ceilings_to_create : Dictionary = {}
var floors_blocked : Dictionary = {} #floors on which obstacles are blocked from spawning
var rooms_to_create : Array[Dictionary] = [] #contains pattern indexes and positions of rooms to be created
var features_to_create : Dictionary = {}
var enemy_spawns : Array[Dictionary] = [{"captures" : null, "position" : Vector2i.ZERO}]

var level : int = 1
var cur_world : String = "grottos"
var cur_level_type : String = "gameplay"

signal stasis_set
signal run_start
signal run_end

signal shop_exited
signal boss_killed

var stasis : bool = false:
	set(new_stasis):
		PhysicsServer2D.set_active(true)
		stasis_set.emit(new_stasis)
		stasis = new_stasis
		
var run_active : bool = false:
	set(new_active):
		run_active = new_active
		if run_active:
			run_start.emit()
		else:
			run_end.emit()

func start_run():
	world = get_tree().get_root().get_node("World")
	camera = world.get_node("Camera")
	controllers = world.get_node("Controllers")
	projectiles = world.get_node("Projectiles")
	nav_region = world.get_node("NavigationRegion2D")
	
	player = controllers.get_node("Player")
	ceilingmap = nav_region.get_node("CeilingMap")
	tilemap = nav_region.get_node("TileMap")
	background = nav_region.get_node("Background")
	
	run_active = true
	
		
# Called when the node enters the scene tree for the first time.
func _ready():
	if not run_active: await run_start
	level = 1
	create_map(level,"grottos","gameplay")
	
func reset_scene(reset_controllers : bool): #reset scenes, clears all tilemaps and entities
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
			
	player.entity.position = Vector2.ZERO
		
func create_map(level : int, world_name : String, level_type : String):
	rooms_to_create = []
	floors_blocked = {}
	floors_to_create = {}
	walls_to_create = {}
	ceilings_to_create = {}
	features_to_create = {}
	enemy_spawns = [{"captures" : null, "position" : Vector2i.ZERO}]
		
	var level_end_pos : Vector2i
	var next_world : String
		
	match world_name + " " + str(level) + " " + level_type:
		"grottos 1 gameplay":
			rooms_to_create.append({ "position" : Vector2i(0,0), "identifier" : "start"})
			level_end_pos = create_path(Vector2i(0,0),40,{Vector2.LEFT : 5, Vector2.RIGHT : 6, Vector2.UP : 5, Vector2.DOWN : 5},Vector2i.ONE,Vector2i(1,1),1,1)
			
			rooms_to_create.append(
				{ "position" : level_end_pos, "identifier" : "end", #identifier - type of room
					"teleporter" : {
						"world" : "grottos", 
						"level" : 2, 
						"type" : "shop"
					}
				}
			)
		"grottos 2 shop":
			rooms_to_create.append(
				{ "position" : level_end_pos, "identifier" : "shop", #identifier - type of room
					"teleporter" : {
						"world" : "grottos", 
						"level" : 2, 
						"type" : "gameplay"
					}
				}
			)
		"grottos 2 gameplay":
			rooms_to_create.append({ "position" : Vector2i(0,0), "identifier" : "start"})
			level_end_pos = create_path(Vector2i(0,0),50,{Vector2.LEFT : 5, Vector2.RIGHT : 6, Vector2.UP : 5, Vector2.DOWN : 5})
			
			rooms_to_create.append(
				{ "position" : level_end_pos, "identifier" : "end", 
					"teleporter" : {
						"world" : "grottos", 
						"level" : 3, 
						"type" : "shop"
					}
				}
			)
		"grottos 3 shop":
			rooms_to_create.append(
				{ "position" : level_end_pos, "identifier" : "shop", #identifier - type of room
					"teleporter" : {
						"world" : "grottos", 
						"level" : 3, 
						"type" : "gameplay"
					}
				}
			)
		"grottos 3 gameplay":
			rooms_to_create.append({ "position" : Vector2i(0,0), "identifier" : "start"})
			level_end_pos = create_path(Vector2i(0,0),60,{Vector2.LEFT : 5, Vector2.RIGHT : 6, Vector2.UP : 5, Vector2.DOWN : 5})
			
			rooms_to_create.append(
				{ "position" : level_end_pos, "identifier" : "end", 
					"teleporter" : {
						"world" : "massif", 
						"level" : 1, 
						"type" : "gameplay"
					}
				}
			)
	write_rooms()
	write_tiles()
	await get_tree().create_timer(0.05).timeout
	spawn_post_processing()
	write_enemies(world_name)
	tilemap.create_features(features_to_create)
	
	var bounding_rect : Rect2i = tilemap.get_used_rect()
	var nav_polygon : NavigationPolygon = NavigationPolygon.new()
	var cell_size = GameDirector.cell_size
	nav_polygon.agent_radius = 4
	var bounding_outline : PackedVector2Array = PackedVector2Array([Vector2i(bounding_rect.position.x-10,bounding_rect.end.y+10)*cell_size,Vector2i(bounding_rect.end.x+10,bounding_rect.end.y+10)*cell_size,Vector2i(bounding_rect.end.x+10,bounding_rect.position.y-10)*cell_size,Vector2i(bounding_rect.position.x-10,bounding_rect.position.y-10)*cell_size])
	nav_polygon.add_outline(bounding_outline)
	nav_region.navigation_polygon = nav_polygon
	nav_region.navigation_polygon.set_parsed_collision_mask_value(5,true)
	
	tilemap.nav_region.bake_navigation_polygon(true)
	
func create_path(origin : Vector2i, limit : float, direction_weights : Dictionary, initial_draw : Vector2i = Vector2i.ONE, overlap_draw : Vector2i = Vector2i.ONE, overlap_chance : float = 0.5, base_captures : float = 0):
	var position : Vector2i = Vector2.ZERO
	var weighted_directions : Array[Vector2i] = []
	for direction in direction_weights:
		for i in direction_weights[direction]:
			weighted_directions.append(Vector2i(direction))
			
	while (position - origin).length() < limit:
		if draw(position,initial_draw):
			if randf() < overlap_chance:
				draw(position,overlap_draw)
				enemy_spawns.append({"captures" : base_captures, "position" : position})
		position += weighted_directions.pick_random()
				
	return position
	
func write_rooms():
	const room_scenes : Dictionary = {
		"shop" : preload("res://Rooms/shop.tscn"),
		"start" : preload("res://Rooms/start.tscn"),
		"end" : preload("res://Rooms/end.tscn"),
		"boss" : preload("res://Rooms/boss.tscn")
	}
	
	for room in rooms_to_create:
		var room_scene : TileMap = room_scenes[room.identifier].instantiate()
		
		var offset = room_scene.get_used_cells_by_id(0,0,Vector2i(0,0))[0]
		var floor_array : Array = room_scene.get_used_cells_by_id(2,1,Vector2i(0,0))
		var wall_array : Array = room_scene.get_used_cells_by_id(2,1,Vector2i(1,0))
		
		for floor in floor_array:
			floors_blocked[floor] = true
			floors_to_create[room.position + floor - offset] = true
			
		for wall in wall_array:
			walls_to_create[room.position + wall - offset] = true
		
		for feature_tile in room_scene.get_used_cells(1):
			var feature
			match room_scene.get_cell_source_id(1,feature_tile):
				3: #entities
					match room_scene.get_cell_atlas_coords(1,feature_tile):
						Vector2i(1,19): #teleporter
							feature = Teleporter.new()
							feature.destination_level = room.teleporter.level
							feature.destination_level_type = room.teleporter.type
							feature.destination_world = room.teleporter.world
						Vector2i(0,19):
							feature = VendingMachine.new()
						Vector2i(2,19):
							feature = BossWall.new()
						Vector2i(0,4):
							feature = Boss.new()
										
			if feature:
				features_to_create[room.position + feature_tile - offset] = feature
		
func write_tiles(): #function for writing tiles to the tilemap
	for floor_tile in floors_to_create:
		
		var terrain_noise : FastNoiseLite = FastNoiseLite.new()
		terrain_noise.seed = randi()
		terrain_noise.frequency = 3
		terrain_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		terrain_noise.fractal_type = FastNoiseLite.FRACTAL_NONE
		
		if terrain_noise.get_noise_2d(floor_tile.x,floor_tile.y) > 0.5:
			tilemap.set_cell(1,floor_tile,1,Vector2i(3,1))
		else:
			tilemap.set_cell(1,floor_tile,1,Vector2i(0,0))
		
		
		
		var vegetation_noise : FastNoiseLite = FastNoiseLite.new()
		vegetation_noise.seed = randi()
		vegetation_noise.frequency = 0.02
		if vegetation_noise.get_noise_3d(floor_tile.x,floor_tile.y,0) > 0.1:
			tilemap.set_cell(2,floor_tile,1,Vector2i(0,1)) #creates grass
		if vegetation_noise.get_noise_3d(floor_tile.x,floor_tile.y,0.2) > 0.2:
			tilemap.set_cell(3,floor_tile,1,Vector2i(0,2)) #creates flowers
		elif vegetation_noise.get_noise_3d(floor_tile.x,floor_tile.y,0.4) > 0.3:
			tilemap.set_cell(3,floor_tile,1,Vector2i(1,2))
		
		
		var rock_noise : FastNoiseLite = FastNoiseLite.new()
		rock_noise.seed = randi()
		rock_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		rock_noise.frequency = 0.2
		rock_noise.fractal_type = FastNoiseLite.FRACTAL_NONE
		if (not floors_blocked.has(floor_tile)) and rock_noise.get_noise_2d(floor_tile.x,floor_tile.y) > 0.7:
			if not features_to_create.has(floor_tile):
				features_to_create[floor_tile] = Rock.new()
			pass
		if rock_noise.get_noise_2d(floor_tile.x,floor_tile.y) > 0.5:
			tilemap.set_cell(3,floor_tile,1,Vector2i(2,2)) #creates flowers
		
		#create walls from floors
		var wall_adjacencies : Array[Vector2i] = [
			Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)]
			
		for adjacency in wall_adjacencies:
			if not walls_to_create.has(floor_tile + adjacency) and not floors_to_create.has(floor_tile + adjacency):
				walls_to_create[floor_tile + adjacency] = true
		#create ceiling from floors
		var ceiling_adjacencies : Array[Vector2i] = [
			Vector2(2,2),Vector2(2,1),Vector2(2,0),Vector2(2,-1),Vector2(2,-2),
			Vector2(1,2),Vector2(1,1),Vector2(1,0),Vector2(1,-1),Vector2(1,-2),
			Vector2(0,2),Vector2(0,1),Vector2(0,-1),Vector2(0,-2),
			Vector2(-2,2),Vector2(-2,1),Vector2(-2,0),Vector2(-2,-1),Vector2(-2,-2),
			Vector2(-1,2),Vector2(-1,1),Vector2(-1,0),Vector2(-1,-1),Vector2(-1,-2),]
						
		for adjacency in ceiling_adjacencies:
			if not ceilings_to_create.has(floor_tile + adjacency) and not floors_to_create.has(floor_tile + adjacency):
				ceilings_to_create[floor_tile + adjacency] = true
			
	for wall_tile in walls_to_create:
		tilemap.set_cell(0,wall_tile,1,Vector2i(1,0))
		
	for ceiling_tile in ceilings_to_create:
		ceilingmap.set_cell(0,ceiling_tile,1,Vector2i(2,0))
		
func write_enemies(world : String):
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
				floors_to_create[local_pos] = true
				
	return overlap >= size.x * size.y #if complete overlap return true else false
	
func spawn_post_processing(): #processes all spawns, for fairness
	var raycast : RayCast2D = RayCast2D.new()
	raycast.set_collision_mask_value(5,true)
	nav_region.add_child(raycast)
					
	#proximity check
	var deleted_spawns : int = 0
	for enemy_spawn_index in len(enemy_spawns):
		var enemy_spawn : Dictionary = enemy_spawns[enemy_spawn_index]
		if enemy_spawn.captures != null:
			var check_depth : int = enemy_spawn.captures * 5 + 3
			for cur_check in check_depth:
				var check_spawn_index = enemy_spawn_index - cur_check - 1
				var check_spawn = enemy_spawns[check_spawn_index]
				if check_spawn_index == 0:
					break
				elif check_spawn.captures != null and (check_spawn.position - enemy_spawn.position).length() < min((enemy_spawn.captures + check_spawn.captures) * 0.2,1)+0.5:
					enemy_spawns[enemy_spawn_index].captures += check_spawn.captures + 1
					enemy_spawns[check_spawn_index].captures = null
	#raycast check
	for enemy_spawn_index in len(enemy_spawns):
		var enemy_spawn : Dictionary = enemy_spawns[enemy_spawn_index]
		if enemy_spawn.captures != null: 
			var check_depth : int = enemy_spawn.captures * 5 + 3
			for cur_check in check_depth:
				var check_spawn_index = enemy_spawn_index - cur_check - 1
				var check_spawn = enemy_spawns[check_spawn_index]
				if check_spawn_index == 0:
					break
				elif check_spawn.captures != null and enemy_spawn.captures != null:
					raycast.position = Vector2i(enemy_spawn.position * cell_size) + Vector2i(cell_size*0.5,cell_size*0.5)
					raycast.target_position = (check_spawn.position - enemy_spawn.position) * cell_size
					raycast.force_raycast_update()
					if (not raycast.is_colliding()) and (check_spawn.position - enemy_spawn.position).length() < 15:
						if randf() > 0.9:
							enemy_spawns[enemy_spawn_index].captures += check_spawn.captures + 1
							enemy_spawns[check_spawn_index].captures = null
	raycast.queue_free()
