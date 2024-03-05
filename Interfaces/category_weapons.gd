extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	GuiDirector.customisation_menu_changed.connect(func():
		match GuiDirector.customisation_menu_type:
			"standard":
				text = "Weapons"	
			"weapon_swap":
				text = "Weapons"
			"module_swap":
				text = "Module Upgrades"
	)
