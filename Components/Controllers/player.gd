extends Controller

class_name Player #controller for the player entity

signal bonds_changed
signal weapon_swapped
signal module_update

var raycast : RayCast2D = RayCast2D.new()
var i_timer : Timer = Timer.new()

var cur_weapon_index : int = 0:
	set(new_weapon_index):
		cur_weapon_index = new_weapon_index
		weapon_swapped.emit()
		
var max_weapons : int = 2

var bonds : int = 0:
	set(new_bonds):
		bonds = new_bonds
		bonds_changed.emit()
		
var modules : Node = Node.new()

var module_dict : Dictionary = {
	1 : null,
	2 : null,
	3 : null,
	1000 : null #reserved for gui 
}
		
func _ready():
	bonds = 2000
	
	generate_weapons()
	
	var basic_weapon : BasicWeapon = preload("res://Components/Weapons/basic_weapon.tscn").instantiate()
	basic_weapon.controller = self
	weapons.add_child(basic_weapon)
	weapon_dict[0] = basic_weapon
	
	skin = "circle"
	
	add_child(modules)
	var speedy : Speedy = preload("res://Components/Modules/speedy.tscn").instantiate()
	speedy.player = self
	modules.add_child.call_deferred(speedy)
	module_dict[0] = speedy
	speedy.activate()
	
	entity.animation_callback.connect(func(identifier : String):
		if not is_instance_valid(GameDirector.player):
			return
		if identifier == "dash":
			entity.modifiers.dash = true
			entity.velocity += entity.get_local_mouse_position().normalized() * 300
			var tween = get_tree().create_tween()
			tween.tween_property(entity,"velocity",Vector2.ZERO,0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tween.finished.connect(func():
				entity.modifiers.dash = false
			)
	)
	
	entity.position = GameDirector.floors_to_create[0] * 20
	
	entity.died.connect(func():
		queue_free()
	)
	
	raycast.set_collision_mask_value(5,true) #levels
	raycast.collide_with_areas = true
	raycast.collide_with_bodies = true
	raycast.add_exception(entity)
	add_child.call_deferred(raycast)
	
	i_timer.autostart = false
	i_timer.one_shot = true 
	add_child.call_deferred(i_timer)
	
	i_timer.timeout.connect(func():
		entity.status_effects.iframe = false
	)
	
	entity.hp_changed.connect(func():
		entity.status_effects.iframe = true
		i_timer.start(0.3)
	)
	
	var old_module_hash : int
	
	while is_instance_valid(modules): #detects differences in weapon update
		await get_tree().create_timer(0.1).timeout
		if old_module_hash != module_dict.hash():
			module_update.emit()
			old_module_hash = module_dict.hash()
	

