extends MarginContainer

@export var upgrade : Control
var index : int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if not visible:
		return
	if Input.is_action_just_pressed("up"):
		index = clampi(index - 1,0,2)
	if Input.is_action_just_pressed("down"):
		index = clampi(index + 1,0,2)
	upgrade.get_parent().move_child(upgrade,index)
