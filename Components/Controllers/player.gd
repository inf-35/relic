extends Controller

class_name Player #controller for the player entity

signal bonds_changed
signal lumen_changed
signal max_lumen_changed
signal weapon_swapped

var i_timer : Timer = Timer.new()

var cur_weapon_index : int = 0:
	set(new_weapon_index):
		cur_weapon_index = new_weapon_index
		weapon_swapped.emit()
		
var max_weapons : int = 1

var weapon_locked : bool = false

var bonds : int = 0:
	set(new_bonds):
		bonds = new_bonds
		bonds_changed.emit()
		
var lumen : float = 20:
	set(new_lumen):
		lumen = new_lumen
		lumen_changed.emit()
		
var max_lumen : int = 20:
	set(new_max_lumen):
		max_lumen = new_max_lumen
		max_lumen_changed.emit()

var attraction_field : Area2D

func _ready():
	if not GameDirector.run_active: await GameDirector.run_start

	bonds = 2000
	
	skin = "player"
	affiliation = "player"
	
	generate_weapons()
	generate_passives()
	generate_nodes()
	
	attraction_field = entity.get_node("Attraction")

	var ultra_weapon : Weapon = BasicWeapon.new()
	ultra_weapon.controller = self
	weapons.add_child(ultra_weapon)
	weapon_dict[2] = ultra_weapon
	
	var f : Weapon = UltraWeapon.new()
	f.controller = self
	weapons.add_child(f)
	weapon_dict[3] = f
	
	var c : Weapon = BasicWeapon.new()
	c.controller = self
	weapons.add_child(c)
	weapon_dict[4] = c
	
	var d : Weapon = UltraWeapon.new()
	d.controller = self
	weapons.add_child(d)
	weapon_dict[5] = d
	
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
		entity.status_effects.iframe.level = 1
		entity.status_effects.iframe.time = 0.4
		entity.parse_stats()
	)
	
func _process(delta):
	lumen *= (1 - 0.2 * delta)
	
	for body in attraction_field.get_overlapping_bodies():
		if "controller" in body and body.controller is LumenPickup:
			var vector : Vector2 = (entity.position - body.position)
			body.velocity += vector.normalized() * delta * 10000 / vector.length()
	
func player_fire(): #specific function for the player to move through to the operation queue
	if weapon_locked:
		await get_tree().create_timer(0.01).timeout
	else:
		if len(active_weapons_array) > cur_weapon_index:
			if active_weapons_array[cur_weapon_index] is Weapon:
				if active_weapons_array[cur_weapon_index].fire(entity.get_local_mouse_position()):
					weapon_locked = true
					await active_weapons_array[cur_weapon_index].cooldown_finished
				
				var benchmark = cur_weapon_index
				cur_weapon_index = (cur_weapon_index + 1) % (len(active_weapons_array))
				while true:
					if active_weapons_array[cur_weapon_index].lumen_cost <= lumen:
						break
					else:
						if cur_weapon_index == benchmark: #loop exhausted
							cur_weapon_index = (cur_weapon_index + 1) % (len(active_weapons_array))
							break
						cur_weapon_index = (cur_weapon_index + 1) % (len(active_weapons_array))
				weapon_locked = false
	

