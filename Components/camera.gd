extends Camera2D

var calibration : int = 1920*1080 #game's ui is designed around 1920 x 1080 as the "default"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().size_changed.connect(func():
		var viewport_size : Vector2 = get_viewport_rect().size
		zoom = Vector2(viewport_size.x * viewport_size.y, viewport_size.x * viewport_size.y) / calibration * 5
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not is_instance_valid(GameDirector.player):
		return
	position = GameDirector.player.entity.position
