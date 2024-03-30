extends Node2D

class_name Controller #abstract class for all controllers

var entity : Entity
var weapons : Node
var property_cache : Dictionary #stores properties for later

var skin : String = "": #determines texture, anims, collision boxes
	set(new_skin):
		generate_skin(new_skin)
		skin = new_skin

var entity_type : String = "" #determines a unique entity type

var weapon_dict : Dictionary = {
	0 : null, #null keys are for the player
	1 : null,
	2 : null,
	1000 : null #key 1000 is for player weapon selection in GUI	
}
var actions_list : Array = []

@export var stasis_exception : bool = false #whether this controller is immune to stasis

signal weapon_update
signal action_signal

func generate_skin(generating_skin):
	y_sort_enabled = true
	z_as_relative = false
	if EntityDirector.entity_skin_scenes.has(generating_skin):
		var skin_entity = load(EntityDirector.entity_skin_scenes[generating_skin]).instantiate()
		add_child.call_deferred(skin_entity)
		entity = skin_entity
		entity.name = "Entity: " + generating_skin
		entity.reset_stats()
		entity.controller = self
		for property in property_cache:
			if property in entity:
				entity[property] = property_cache[property]
	else:
		push_error(generating_skin, " skin does not exist!")
	
	GameDirector.stasis_set.connect(func(new_stasis):
		if stasis_exception or not is_instance_valid(entity):
			return
			
		if new_stasis:
			for child in get_children():
				if child is Timer:
					child.paused = true
					
			if not entity.animation_player:
				return
	
			if entity.animation_player.current_animation != "":
				entity.animation_player.pause()
		else:
			for child in get_children():
				if child is Timer:
					child.paused = false
				
			if not entity.animation_player:
				return
			
			if entity.animation_player.current_animation != "":
				entity.animation_player.play()
				

	)

func generate_weapons():
	var old_weapon_hash : int = weapon_dict.hash()
	
	weapons = Node.new()
	weapons.name = "Weapons"
	add_child(weapons)
	
	weapons.child_exiting_tree.connect(func(weapon):
		if weapon_dict.find_key(weapon):
			weapon_dict[weapon_dict.find_key(weapon)] = null
	)
	
	while is_instance_valid(weapons): #detects differences in weapon update
		await get_tree().create_timer(0.1).timeout
		if old_weapon_hash != weapon_dict.hash():
			weapon_update.emit()
		old_weapon_hash = weapon_dict.hash()
	

