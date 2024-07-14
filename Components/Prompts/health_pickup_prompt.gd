extends Prompt

class_name HealthPickupPrompt

var health : float = 0

func action(actor):
	actor.entity.hp += health
		
	get_parent().queue_free()
