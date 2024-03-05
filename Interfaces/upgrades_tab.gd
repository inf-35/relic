extends MarginContainer

class_name UpgradesTab

@export var upgrade : Control
var index : int = 0:
	set(new_index):
		index = new_index
		upgrade.get_parent().move_child(upgrade,index)
		if upgrade.get_node_or_null("UiShake"):
			upgrade.get_node("UiShake").start_shake()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if not visible:
		return
	if Input.is_action_just_pressed("up"):
		index = clampi(index - 1,0,2)
	if Input.is_action_just_pressed("down"):
		index = clampi(index + 1,0,2)
