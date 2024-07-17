extends Controller

class_name Grunt

var state : String = "loiter":
	set(new_state):
		match new_state:
			"loiter":
				timer.start(2)
			"chase":
				timer.start(0.5)
			"surround":
				timer.start(2)
			"retreat":
				timer.start(0.5)
			"aiming":
				timer.start(0.5)
		state = new_state
		
# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
		
	skin = "grunt"
	affiliation = "enemy"
	
	generate_weapons()
	generate_nodes()
	
	var basic_weapon : BasicWeapon = BasicWeapon.new()
	basic_weapon.controller = self
	weapons.add_child(basic_weapon)
	weapon_dict[0] = basic_weapon
	
	entity.animation_callback.connect(func(identifier : String):
		if not is_instance_valid(GameDirector.player):
			return
		
		match identifier:
			"telegraph":
				state = "aiming" #freezes the enemy
				var indicator : AttackIndicator = AttackIndicator.new()
				indicator.rotation = (GameDirector.player.entity.position + GameDirector.player.entity.main_hitbox.position - entity.position).angle()
				indicator.shape = "rect"
				indicator.size = Vector2(5,20)
				indicator.radius = 20
				indicator.position = entity.position
				add_child(indicator)
				
				await get_tree().create_timer(0.5).timeout
				indicator.close()
			
			"shoot":
				state = "surround"
				weapon_dict[0].fire((GameDirector.player.entity.position + GameDirector.player.entity.main_hitbox.position - entity.position).normalized())
	)
	
	entity.died.connect(func():
		var health_pickup : HealthPickup = HealthPickup.new()
		health_pickup.property_cache.position = entity.position
		health_pickup.property_cache.velocity = Vector2(30,30)
		health_pickup.property_cache.friction = 5
		health_pickup.health = 6
		GameDirector.projectiles.add_child.call_deferred(health_pickup)
		queue_free.call_deferred()
		
		#var credit : Credit = preload("res://Components/credit.tscn").instantiate()
		#credit.position = entity.position
		#GameDirector.projectiles.add_child.call_deferred(credit)
		#queue_free.call_deferred()
	)
	
	entity.hp_changed.connect(func():
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
			if (entity.position - GameDirector.player.entity.position).length() < 110:
				state = "surround"
				return
			elif (entity.position - GameDirector.player.entity.position).length() > 220:
				state = "loiter"
				return
				
			if timer.time_left == 0:
				nav_agent.target_position = GameDirector.player.entity.position
				timer.start(0.5)
		"surround": #60 ~ 120 (margin : 10)
			if (entity.position - GameDirector.player.entity.position).length() > 130:
				state = "chase"
				return
			elif (entity.position - GameDirector.player.entity.position).length() < 50:
				state = "retreat"
				return
				
			if weapon_timer.time_left == 0:
				raycast.position = entity.position
				raycast.target_position = GameDirector.player.entity.position - entity.position
				raycast.force_raycast_update()

				if "entity" in raycast.get_collider() and raycast.get_collider().entity == GameDirector.player.entity:
					entity.animation_player.play("shoot")
					weapon_timer.start(2)
				
			if timer.time_left == 0:
				var attempts : int = 0
				while true:
					attempts += 1
					nav_agent.target_position = entity.position + Vector2(randf_range(-40,40),randf_range(-40,40))
					if nav_agent.is_target_reachable() and (nav_agent.target_position - GameDirector.player.entity.position).length() < 120 and (nav_agent.target_position - GameDirector.player.entity.position).length() > 60:
						raycast.position = nav_agent.target_position
						raycast.target_position = GameDirector.player.entity.position - nav_agent.target_position
						raycast.force_raycast_update()
						
						if randf() > 0.8 or raycast.get_collider() == GameDirector.player.entity:
							break
					elif attempts > 10:
						nav_agent.target_position = entity.position
						break
				timer.start(2)
				
		"retreat": #<60 (margin : 10)
			if (entity.position - GameDirector.player.entity.position).length() > 70:
				state = "chase"
				return
			
			if timer.time_left == 0:
				nav_agent.target_position = entity.position + (entity.position - GameDirector.player.entity.position).normalized() * 40
				timer.start(0.5)
				
			if weapon_timer.time_left == 0:
				raycast.position = entity.position
				raycast.target_position = GameDirector.player.entity.position - entity.position
				raycast.force_raycast_update()

				if "entity" in raycast.get_collider() and raycast.get_collider().entity == GameDirector.player.entity:
					entity.animation_player.play("shoot")
					weapon_timer.start(2)
		"aiming":
			nav_agent.target_position = entity.position
	
	nav_agent.set_velocity(entity.to_local(nav_agent.get_next_path_position()).normalized() * entity.speed_perc * entity.stats.movement_speed.final)

