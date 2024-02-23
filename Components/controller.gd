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

var weapons_list : Array = []
		
var actions_list : Array = []

@export var stasis_exception : bool = false #whether this controller is immune to stasis

signal weapons_update

func generate_skin(generating_skin):
	y_sort_enabled = true
	z_as_relative = false
	if EntityDirector.entity_skin_scenes.has(generating_skin):
		var skin_entity = EntityDirector.entity_skin_scenes[generating_skin].instantiate()
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
		if stasis_exception:
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
	weapons = Node.new()
	weapons.name = "Weapons"
	add_child(weapons)	
	

