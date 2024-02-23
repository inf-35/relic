extends Controller

class_name Player #controller for the player entity

signal bonds_changed
signal weapon_swapped

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
		
func _ready():
	bonds = 2000
	
	weapons_list = [null,null,null]
	generate_weapons()
	skin = "circle"
	
	add_child(modules)
	var speedy : Speedy = preload("res://Components/Modules/speedy.tscn").instantiate()
	speedy.player = self
	modules.add_child.call_deferred(speedy)
	speedy.activate()
	
	BasicWeapon.new(self)
	
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
