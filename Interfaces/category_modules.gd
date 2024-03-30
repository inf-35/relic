extends RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	GuiDirector.customisation_menu_changed.connect(func():
		match GuiDirector.customisation_menu_type:
			"standard":
				text = "Modules"
			"weapon_swap":
				text = "Modules"
			"module_swap":
				text = "Weapon Upgrades"
	)
