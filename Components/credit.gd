extends Area2D

class_name Credit

func _on_area_entered(area : Area2D):
	if not area is Hitbox:
		return
		
	if not area.entity:
		return
		
	if not area.entity.controller is Player:
		return

	var player = area.entity.controller
	player.bonds += 20
	queue_free()
