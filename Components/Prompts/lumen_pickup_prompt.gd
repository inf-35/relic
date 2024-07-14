extends Prompt

class_name LumenPickupPrompt

var lumen : float = 0

func action(actor):
	if "lumen" in actor:
		actor.lumen += lumen
			
		get_parent().queue_free()
