extends Node2D

class_name Controller #abstract class for all controllers

var entity : Entity

var affiliation : String:
	set(new_affiliation):
		affiliation = new_affiliation

var weapons : Node
var passives : Node

var property_cache : Dictionary #stores properties for later
var skin : String = "": #determines texture, anims, collision boxes
	set(new_skin):
		generate_skin(new_skin)
		skin = new_skin

var weapon_dict : Dictionary = {
	0 : null, #null keys are for the player
	1000 : null #key 1000 is for player weapon selection in GUI	
}

var active_weapons_array : Array = []

var sorted_weapon_key_array : Array = []

var actions_list : Array = []

var passive_dict : Dictionary = {
	0 : null,
	1000 : null,
}

@export var stasis_exception : bool = false #whether this controller is immune to stasis

var nav_agent : NavigationAgent2D = NavigationAgent2D.new()
var raycast : RayCast2D = RayCast2D.new()
var raycast_timer : Timer = Timer.new()
var weapon_timer : Timer = Timer.new()
var timer : Timer = Timer.new()

signal weapon_update
signal passive_update
signal action_signal

func generate_nodes():
	nav_agent.path_desired_distance = 0.5
	nav_agent.avoidance_enabled = true
	nav_agent.radius = 5
	nav_agent.time_horizon = 0.8
	
	nav_agent.velocity_computed.connect(func(vel):
		entity.movement_vector = vel.normalized()
	)
	
	entity.add_child(nav_agent)
	
	timer.autostart = false
	timer.one_shot = true
	add_child(timer)
	
	weapon_timer.autostart = false
	weapon_timer.one_shot = true
	add_child(weapon_timer)
	
	add_child(raycast)
	raycast_timer.one_shot = false
	raycast_timer.timeout.connect(func a():
		if not is_instance_valid(GameDirector.player):
			return 
		raycast.position = entity.position
		raycast.target_position = entity.to_local(GameDirector.player.entity.position)
		raycast.force_raycast_update()
	)
	add_child(raycast_timer)
	raycast_timer.start(0.2)

func generate_skin(generating_skin):
	y_sort_enabled = true
	z_as_relative = false
	
	var skin_entity = EntityAbstraction.spawn_request(generating_skin)
	if skin_entity:
		add_child.call_deferred(skin_entity)
		entity = skin_entity
		entity.name = "Entity: " + generating_skin
		entity.reset_stats()
		entity.controller = self
		for property in property_cache:
			if property in entity:
				entity[property] = property_cache[property]
	#
	#GameDirector.stasis_set.connect(func(new_stasis):
		#if stasis_exception or not is_instance_valid(entity):
			#return
			#
		#if new_stasis:
			#for child in get_children():
				#if child is Timer:
					#child.paused = true
					#
			#if not entity.animation_player:
				#return
				#
			#if entity.animation_player.current_animation != "":
				#entity.animation_player.pause()
		#else:
			#for child in get_children():
				#if child is Timer:
					#child.paused = false
				#
			#if not entity.animation_player:
				#return
			#
			#if entity.animation_player.current_animation != "":
				#entity.animation_player.play()
	#)

func generate_weapons():
	var old_weapon_hash : int = weapon_dict.hash()
	
	weapons = Node.new()
	weapons.name = "Weapons"
	add_child(weapons)
	
	weapons.child_exiting_tree.connect(func(weapon):
		if weapon_dict.find_key(weapon):
			weapon_dict[weapon_dict.find_key(weapon)] = null
	)
	
	compile_weapons()
	
	while is_instance_valid(weapons): #detects differences in weapon dict
		await get_tree().create_timer(0.1).timeout
		if old_weapon_hash != weapon_dict.hash():
			compile_weapons()
			weapon_update.emit()
		old_weapon_hash = weapon_dict.hash()
		
func generate_passives():
	var old_passive_hash : int = passive_dict.hash()
	
	passives = Node.new()
	passives.name = "Passives"
	add_child(passives)
	
	passives.child_exiting_tree.connect(func(passive):
		if passive_dict.find_key(passive):
			passive_dict[passive_dict.find_key(passive)] = null
	)
	
	while is_instance_valid(passives): #detects differences in weapon update
		await get_tree().create_timer(0.1).timeout
		if old_passive_hash != passive_dict.hash():
			passive_update.emit()
			old_passive_hash = passive_dict.hash()

func compile_weapons(): #assign active weapons and secondaries
	sorted_weapon_key_array = []
	active_weapons_array = []
	for weapon in weapon_dict:
		sorted_weapon_key_array.append(weapon)
	sorted_weapon_key_array.sort() #sorted array of all keys in weapon dict
	
	var cur_target_weapon = null
	for weapon_key in sorted_weapon_key_array:
		if not weapon_dict[weapon_key]:
			continue
			
		if weapon_key == 1000:
			break
			
		if weapon_dict[weapon_key].primary: #creates primary-secondary relationships
			cur_target_weapon = weapon_dict[weapon_key]
			cur_target_weapon.secondaries.clear()
			cur_target_weapon.targeted_primary = null
			
			active_weapons_array.append(cur_target_weapon)
		elif cur_target_weapon:
			cur_target_weapon.secondaries.append(weapon_dict[weapon_key])
			weapon_dict[weapon_key].targeted_primary = cur_target_weapon
		for active_weapon in active_weapons_array:
			active_weapon.trigger_secondaries()
			
#func _exit_tree():
	#remove_child(entity)
	#if EntityAbstraction.skin_pools.has(skin):
		#EntityAbstraction.skin_pools[skin].append(entity)


