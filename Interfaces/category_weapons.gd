extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	GuiDirector.customisation_menu_changed.connect(func():
		match GuiDirector.customisation_menu_type:
			"standard":
				text = "[center]Weapons"	
			"weapon_swap":
				text = "[center]Weapons"
			"module_swap":
				text = "[center]Module Upgrades"
	)
