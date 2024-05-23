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
var floors_occupied : Dictionary = {} #floors unavailable for spawning
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
			level_end_pos = write_room({ "position" : Vector2i(0,0), "identifier" : "start"})
			level_end_pos = create_path(level_end_pos,50,{Vector2(0,2) : 2, Vector2(0,-2) : 3, Vector2(2,0) : 2, Vector2(-2,0) : 2},Vector2i(3,3))
			
			level_end_pos = write_room(
				{ "position" : level_end_pos, "identifier" : "end", #identifier - type of room
					"teleporter" : {
						"world" : "grottos", 
						"level" : 2, 
						"type" : "shop"
					}
				}
			)

			place_features(floors_to_create,0.9,Vector2i(1,1),Grunt.new())
			place_features(floors_to_create,0.95,Vector2i(2,2),Beetle.new())
			place_features(floors_to_create,0.2,Vector2i(2,2),Rock.new())
		"grottos 2 shop":
			write_room(
				{ "position" : level_end_pos, "identifier" : "shop", #identifier - type of room
					"teleporter" : {
						"world" : "grottos", 
						"level" : 2, 
						"type" : "gameplay"
					}
				}
			)
		"grottos 2 gameplay":
			level_end_pos = write_room({"position" : Vector2i(0,0),"identifier" : "start"})
			level_end_pos = create_path(level_end_pos,30,{Vector2.LEFT : 5, Vector2.RIGHT : 6, Vector2.UP : 5, Vector2.DOWN : 5})
			level_end_pos = write_room({"position" : level_end_pos,"identifier" : "boss"})
			
			level_end_pos = write_room(
				{ "position" : level_end_pos, "identifier" : "end", 
					"teleporter" : {
						"world" : "grottos", 
						"level" : 3, 
						"type" : "shop"
					}
				}
			)
			
			place_features(floors_to_create,0.9,Vector2i(1,1),Grunt.new())
			place_features(floors_to_create,0.9,Vector2i(2,2),Beetle.new())
		
	write_tiles()
	await get_tree().create_timer(0.05).timeout
	spawn_post_processing()
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
	
func create_path(origin : Vector2i, limit : float, direction_weights : Dictionary, initial_draw : Vector2i = Vector2i.ONE, base_captures : float = 0) -> Vector2i:
	var position : Vector2i = origin
	var weighted_directions : Array[Vector2i] = []
	for direction in direction_weights:
		for i in direction_weights[direction]:
			weighted_directions.append(Vector2i(direction))
			
	while (position - origin).length() < limit:
		draw(position,initial_draw)
		position += weighted_directions.pick_random()
				
	return position
	
func write_room(room) -> Vector2i:
	const room_scenes : Dictionary = {
		"shop" : preload("res://Rooms/shop.tscn"),
		"start" : preload("res://Rooms/start.tscn"),
		"end" : preload("res://Rooms/end.tscn"),
		"boss" : preload("res://Rooms/boss.tscn")
	}
	
	var room_scene : TileMap = room_scenes[room.identifier].instantiate()
	
	var offset = room_scene.get_used_cells_by_id(0,0,Vector2i(0,0))[0]
	var exit = room_scene.get_used_cells_by_id(0,0,Vector2i(0,1))[0]
	var floor_array : Array = room_scene.get_used_cells_by_id(2,1,Vector2i(0,0))
	var wall_array : Array = room_scene.get_used_cells_by_id(2,1,Vector2i(1,0))
	
	for floor in floor_array:
		floors_blocked[room.position + floor - offset] = true
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
				
	return room.position + exit - offset
		
func write_tiles(): #function for writing tiles to the tilemap
	
	for floor_tile in floors_to_create:
		tilemap.set_cell(1,floor_tile,1,Vector2i(0,0))
		
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
		
		write_walls()
		write_ceilings()
				
func noise_decor(tiles_to_check, frequency : float,threshold : float,tilemap_layer : int,source_id : int,atlas_coords : Vector2i,ignore_blockers : bool = false,ignore_occupiers : bool = false,seed : int = randi()):
	for pos in tiles_to_check:
		if not ignore_blockers:
			if floors_blocked.has(pos):
				continue
		if not ignore_occupiers:
			if floors_occupied.has(pos):
				continue
		
		var noise = FastNoiseLite.new()
		noise.seed = seed
		noise.frequency = frequency
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		noise.fractal_type = FastNoiseLite.FRACTAL_NONE
		
		if noise.get_noise_2d(pos.x,pos.y) > threshold:
			tilemap.set_cell(tilemap_layer,pos,source_id,atlas_coords)
		
func noise_features(tiles_to_check,frequency : float,threshold : float,feature : Node,ignore_blockers : bool = false,ignore_occupiers : bool = false,seed : int =randi()):
	for pos in tiles_to_check:
		if not ignore_blockers:
			if floors_blocked.has(pos):
				continue
		if not ignore_occupiers:
			if floors_occupied.has(pos):
				continue
		
		var noise = FastNoiseLite.new()
		noise.seed = seed
		noise.frequency = frequency
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		noise.fractal_type = FastNoiseLite.FRACTAL_NONE
		
		if noise.get_noise_2d(pos.x,pos.y) > threshold:
			features_to_create[pos] = feature.duplicate(7)
			floors_occupied[pos] = true
	feature.free()
		
func place_features(tiles_to_check, threshold : float, size : Vector2i, feature : Node,ignore_blockers = false,ignore_occupiers = false,seed=randi()):
	for pos in tiles_to_check:
		var valid : bool = true
		for x in size.x:
			for y in size.y:
				var local_pos : Vector2i = Vector2i(pos.x + x, pos.y + y)
				if not floors_to_create.has(local_pos):
					valid = false
					break
				if (not ignore_blockers) and (floors_blocked.has(local_pos)):
					valid = false
					break
				if (not ignore_occupiers) and (floors_occupied.has(local_pos)):
					valid = false
					break
			if not valid:
				break
		if valid:
			if randf() > threshold:
				features_to_create[pos] = feature.duplicate(7)
				for x in size.x:
					for y in size.y:
						floors_occupied[Vector2i(pos.x + x,pos.y + y)] = true
	feature.free()

func write_ceilings():
	for ceiling_tile in ceilings_to_create:
		ceilingmap.set_cell(0,ceiling_tile,1,Vector2i(2,0))
		
func write_walls():
	for wall_tile in walls_to_create:
		tilemap.set_cell(0,wall_tile,1,Vector2i(1,0))
		
func draw(start : Vector2i, size : Vector2i) -> bool:
	var overlap : int = 0
	for x in size.x:
		for y in size.y:
			var local_pos : Vector2i = Vector2i(start.x + x,start.y + y)
			floors_to_create[local_pos] = true
				
	return overlap >= size.x * size.y #if complete overlap return true else false
	
func spawn_post_processing(): #processes all spawns, for fairness
	#for floor in floors_to_create:
		##enemy_spawns.append({"position" : floor,"captures" : 0})
		
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
