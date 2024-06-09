extends Camera2D

class_name Camera

var calibration : int = 1920*1080 #game's ui is designed around 1920 x 1080 as the "default"
var base_camera_vel : Vector2 = Vector2.ZERO
var shake_vector : Vector2 = Vector2.ZERO:
	set(new_vector):
		shake_vector = new_vector
		if shake_vector.length_squared() < 0.5:
			shake_significant = false
		else:
			shake_significant = true
var shake_significant : bool = false
var cursor_influence : float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	get_viewport().size_changed.connect(func():
		var viewport_size : Vector2 = get_viewport_rect().size
		zoom = Vector2(viewport_size.x * viewport_size.y, viewport_size.x * viewport_size.y) / calibration * 5
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float):
	if not is_instance_valid(GameDirector.player): return
	
	if shake_significant:
		shake_vector = shake_vector.rotated(deg_to_rad(randf_range(170,190))) * 0.5
		
	var target_pos : Vector2 = GameDirector.player.entity.position.lerp(get_global_mouse_position(),cursor_influence)
	if not is_instance_valid(GameDirector.player):
		return
	base_camera_vel = (target_pos - position)
	position += (base_camera_vel * 10) * delta
	position += shake_vector
