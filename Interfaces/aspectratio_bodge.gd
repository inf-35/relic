extends AspectRatioContainer

class_name AspectRatioFixed

var child_array : Array[Node] = []

func _enter_tree():
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	
	resized.connect(func():
		custom_minimum_size = Vector2.ZERO
		set_minimum_size()
		stretch_mode = AspectRatioContainer.STRETCH_COVER
	)

func _ready():
	clip_contents = false
	
func _on_child_entered_tree(new_child : Node):
	if new_child is Control:
		custom_minimum_size = Vector2.ZERO
		child_array.append(new_child)
		set_minimum_size()
		new_child.resized.connect(func():
			set_minimum_size()
		)
		stretch_mode = AspectRatioContainer.STRETCH_COVER

		
func _on_child_exiting_tree(leaving_child : Node):
	if leaving_child:
		child_array.erase(leaving_child)
		set_minimum_size()
	
func set_minimum_size():
	var max_x : float = 0
	var max_y : float = 0
	for child in child_array:
		if child.size.x > max_x:
			max_x = child.size.x
		if child.size.y > max_y:
			max_y = child.size.y
	set_custom_minimum_size(Vector2(max_x,max_y))
