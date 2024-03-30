extends Controller

class_name Grunt

var nav_agent : NavigationAgent2D = NavigationAgent2D.new()
var raycast : RayCast2D = RayCast2D.new()
var raycast_timer : Timer = Timer.new()
var weapon_timer : Timer = Timer.new()
var timer : Timer = Timer.new()
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
		state = new_state
		
# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
		
	generate_weapons()
	
	var basic_weapon : BasicWeapon = preload("res://Components/Weapons/basic_weapon.tscn").instantiate()
	basic_weapon.controller = self
	weapons.add_child(basic_weapon)
	weapon_dict[0] = basic_weapon
	
	skin = "grunt"
	
	entity.animation_callback.connect(func(identifier : String):
		if not is_instance_valid(GameDirector.player):
			return
		if identifier == "shoot":
			weapon_dict[0].fire((GameDirector.player.entity.position + GameDirector.player.entity.main_hitbox.position - entity.position).normalized())
	)

	nav_agent.path_desired_distance = 0.5
	nav_agent.avoidance_enabled = true
	nav_agent.radius = 5
	nav_agent.time_horizon = 0.8
	
	nav_agent.velocity_computed.connect(func(vel):
		entity.movement_vector = vel.normalized()
	)
	
	entity.add_child.call_deferred(nav_agent)
	
	timer.autostart = false
	timer.one_shot = true
	add_child(timer)
	
	weapon_timer.autostart = false
	weapon_timer.one_shot = true
	add_child(weapon_timer)
	
	raycast_timer.one_shot = false
	raycast_timer.timeout.connect(func a():
		if not is_instance_valid(GameDirector.player):
			return
		if (entity.position - GameDirector.player.entity.position).length() > 400:
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
	add_child.call_deferred(raycast)
	
	entity.died.connect(func():
		var credit : Credit = preload("res://Components/credit.tscn").instantiate()
		credit.position = entity.position
		GameDirector.projectiles.add_child.call_deferred(credit)
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
		"chase": #120+ (margin : 10)
			if (entity.position - GameDirector.player.entity.position).length() < 110:
				state = "surround"
				return
			elif (entity.position - GameDirector.player.entity.position).length() > 280:
				state = "loiter"
				return
				
			if weapon_timer.time_left == 0:
				entity.animation_player.play("shoot")
				weapon_timer.start(2)
				
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
				state = "surround"
				return
			
			if timer.time_left == 0:
				nav_agent.target_position = entity.position + (entity.position - GameDirector.player.entity.position).normalized() * 40
				timer.start(0.5)
			
	nav_agent.set_velocity(entity.to_local(nav_agent.get_next_path_position()).normalized() * entity.speed_perc * entity.stats.movement_speed.final)

