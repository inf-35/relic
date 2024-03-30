extends Controller

class_name Beetle

var nav_agent : NavigationAgent2D = NavigationAgent2D.new()
var raycast : RayCast2D = RayCast2D.new()
var raycast_timer : Timer = Timer.new()
var bounce_timer : Timer = Timer.new()
var timer : Timer = Timer.new()
var state : String = "loiter":
	set(new_state):
		match new_state:
			"loiter":
				timer.start(2)
			"chase":
				timer.start(0.2)
			"surround":
				timer.start(2)
			"retreat":
				timer.start(0.2)
		state = new_state
		
# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	generate_weapons()
	
	var basic_weapon : RoundWeapon = preload("res://Components/Weapons/round_weapon.tscn").instantiate()
	basic_weapon.controller = self
	weapons.add_child(basic_weapon)
	weapon_dict[0] = basic_weapon
	
	skin = "beetle"
	
	entity.animation_callback.connect(func(identifier : String):
		if not is_instance_valid(GameDirector.player):
			return
		if identifier == "fire":
			weapon_dict[0].fire((GameDirector.player.entity.position + GameDirector.player.entity.main_hitbox.position - entity.position).normalized())
			entity.velocity = (nav_agent.get_next_path_position() - entity.position).normalized() * entity.stats.movement_speed.final * 100
			
	)
	
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
	
	bounce_timer.autostart = false
	bounce_timer.one_shot = true
	add_child(bounce_timer)
	
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
	
	raycast.set_collision_mask_value(5,true) #levels
	raycast.collide_with_areas = true
	raycast.collide_with_bodies = true
	raycast.set_collision_mask_value(2,false)
	raycast.add_exception(entity)
	add_child(raycast)
	
	entity.died.connect(func():
		var dropped_weapon : DroppedWeapon = DroppedWeapon.new()
		dropped_weapon.weapon_name = "ultra_weapon"
		dropped_weapon.property_cache.position = entity.position
		GameDirector.projectiles.add_child.call_deferred(dropped_weapon)
		queue_free.call_deferred()
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameDirector.stasis:
		entity.immobile = true
		return
	else:
		entity.immobile = false
		
	
	if not is_instance_valid(GameDirector.player):
		return
	
	#ai throttling
	if (entity.position - GameDirector.player.entity.position).length() > 400:
		nav_agent.radius = 0
	else:
		nav_agent.radius = 5
	
	match state:
		"loiter":
			if not raycast.get_collider():
				return
				
			if raycast.get_collider() == GameDirector.player.entity or raycast.get_collider().get_parent() == GameDirector.player.entity:
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
				
		"chase": 
			if bounce_timer.time_left == 0:
				bounce_timer.start(2)
				var indicator : AttackIndicator = AttackIndicator.new()
				indicator.shape = "arc"
				indicator.arc_angle = 360
				indicator.radius = 20
				indicator.position = entity.position
				add_child(indicator)
				
				await get_tree().create_timer(0.5).timeout
				indicator.close()
				entity.animation_player.play("jump")
				
			if timer.time_left == 0:
				nav_agent.target_position = GameDirector.player.entity.position
				timer.start(0.2)
		

