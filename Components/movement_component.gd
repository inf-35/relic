extends Node

class_name MovementComponent

func movement(node : Entity,movement_vector,movement_speed,speed_perc,delta):
	node.velocity += movement_vector * movement_speed * speed_perc * delta * 100
	node.move_and_slide()
	
func friction(node : Entity,damping):
	node.velocity *= damping
