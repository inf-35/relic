extends Controller

class_name Bomb

var state : String = "loiter":
	set(new_state):
		match new_state:
			"loiter":
				timer.start(2)
			"chase":
				timer.start(0.5)
			"detonating":
				timer.start(0.5)
		state = new_state
		
# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
		
	skin = "bomb"
	affiliation = "enemy"
	
	generate_weapons()
	generate_nodes()
	
	var basic_weapon : Weapon = BombWeapon.new()
	basic_weapon.controller = self
	weapons.add_child(basic_weapon)
	weapon_dict[0] = basic_weapon
	
	entity.animation_callback.connect(func(identifier : String):
		if not is_instance_valid(GameDirector.player):
			return
		
		match identifier:
			"telegraph":
				state = "detonating" #freezes the enemy
				var indicator : AttackIndicator = AttackIndicator.new()
				indicator.shape = "arc"
				indicator.arc_angle = 360
				indicator.radius = 10
				indicator.position = entity.position
				add_child(indicator)
				
				await get_tree().create_timer(0.5).timeout
				indicator.close()
			
			"shoot":
				state = "surround"
				var explosion : Explosion = Explosion.new()
				explosion.property_cache.position = entity.position
				queue_free.call_deferred()
	)
	
	entity.died.connect(func():
		weapon_dict[0].fire((GameDirector.player.entity.position + GameDirector.player.entity.main_hitbox.position - entity.position).normalized())
		queue_free.call_deferred()
	)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameDirector.stasis:
		return
	
	if not is_instance_valid(GameDirector.player):
		return
	
	#ai throttling
	if (entity.position - GameDirector.player.entity.position).length_squared() > 100000:
		nav_agent.radius = 0
	else:
		nav_agent.radius = 5
		
	match state:
		"loiter":
			if (GameDirector.player.entity.position - entity.position).length_squared() > 120000:
				return
				
			if (GameDirector.player.entity.position - entity.position).length_squared() < 100000 and raycast.get_collider() and (raycast.get_collider() == GameDirector.player.entity or raycast.get_collider().get_parent() == GameDirector.player.entity):
				state = "chase"
				return
				
			if timer.time_left == 0:
				var attempts : int = 0
				while true:
					attempts += 1
					nav_agent.target_position = entity.position + Vector2(randf_range(-40,40),randf_range(-40,40))
					if nav_agent.is_target_reachable():
						break
					elif attempts > 5:
						nav_agent.target_position = entity.position
						break
				timer.start(2)
				
		"chase": #120+ (margin : 10)
			if (entity.position - GameDirector.player.entity.position).length() > 220:
				state = "loiter"
				return
			
			if (entity.position - GameDirector.player.entity.position).length() < 20:
				entity.animation_player.play("shoot")
				state = "detonating"
				return
				
			if timer.time_left == 0:
				nav_agent.target_position = GameDirector.player.entity.position
				timer.start(0.5)
				
	
	nav_agent.set_velocity(entity.to_local(nav_agent.get_next_path_position()).normalized() * entity.speed_perc * entity.stats.movement_speed.final)

