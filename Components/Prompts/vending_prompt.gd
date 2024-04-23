extends Prompt

class_name VendingPrompt

func action(actor):
	if actor is Player:
		GuiDirector.customisation_menu_type = "shop"
		GuiDirector.customisation_menu_visible = true
