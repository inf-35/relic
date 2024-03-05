@tool
extends AspectRatioContainer

class_name AspectRatioFixed

var child : Control

func _enter_tree():
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	
	resized.connect(func():
		stretch_mode = AspectRatioContainer.STRETCH_FIT
		await get_tree().create_timer(0.01).timeout
		set_custom_minimum_size(Vector2(child.size.x,0))
		await get_tree().create_timer(0.01).timeout
		stretch_mode = AspectRatioContainer.STRETCH_COVER
	)
	
func _on_child_entered_tree(new_child : Node):
	if new_child is Control:
		stretch_mode = AspectRatioContainer.STRETCH_FIT
		await get_tree().create_timer(0.01).timeout
		child = new_child
		set_custom_minimum_size(Vector2(child.size.x,0))
		child.resized.connect(func():
			set_custom_minimum_size(Vector2(child.size.x,0))
		)
	await get_tree().create_timer(0.01).timeout
	stretch_mode = AspectRatioContainer.STRETCH_COVER

		
func _on_child_exiting_tree(leaving_child : Node):
	if leaving_child == child:
		child = null
		set_custom_minimum_size(Vector2(0,0))
	


func _on_weapon_item_rect_changed():
	pass # Replace with function body.
