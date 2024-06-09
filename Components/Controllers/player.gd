extends Controller

class_name Player #controller for the player entity

signal bonds_changed
signal weapon_swapped


var i_timer : Timer = Timer.new()

var cur_weapon_index : int = 0:
	set(new_weapon_index):
		cur_weapon_index = new_weapon_index
		weapon_swapped.emit()
		
var max_weapons : int = 1

var bonds : int = 0:
	set(new_bonds):
		bonds = new_bonds
		bonds_changed.emit()
		
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start

	bonds = 2000
	
	skin = "player"
	affiliation = "player"
	
	generate_weapons()
	generate_passives()
	generate_nodes()
	
	#var basic_weapon : UltraWeapon = UltraWeapon.new()
	#basic_weapon.controller = self
	#weapons.add_child(basic_weapon)
	#weapon_dict[0] = basic_weapon
	#
	#var modifier : ModifierWeapon = ModifierWeapon.new()
	#modifier.controller = self
	#weapons.add_child(modifier)
	#weapon_dict[1] = modifier
	
	var ultra_weapon : Weapon = BasicWeapon.new()
	ultra_weapon.controller = self
	weapons.add_child(ultra_weapon)
	weapon_dict[2] = ultra_weapon
	
	var speedy : Speedy = preload("res://Components/passives/speedy.tscn").instantiate()
	speedy.player = self
	passives.add_child.call_deferred(speedy)
	passive_dict[0] = speedy
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
	
	entity.died.connect(func():
		queue_free()
	)
	
	entity.entity_hit.connect(func():
		entity.status_effects.iframe = 0.3
		entity.parse_stats()
	)
	

