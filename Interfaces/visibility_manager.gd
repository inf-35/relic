extends Control

@onready var weapons : MarginContainer = get_node("Middle/Weapons")
@onready var modules : MarginContainer = get_node("Middle/Modules")
@onready var weapon_upgrades : MarginContainer = get_node("Middle/WeaponUpgrades")
@onready var module_upgrades : MarginContainer = get_node("Middle/ModuleUpgrades")
# Called when the node enters the scene tree for the first time.
func _ready():
	GuiDirector.customisation_menu_changed.connect(func():
		print(GuiDirector.customisation_menu_type)
		match GuiDirector.customisation_menu_type:
			"standard":
				weapons.visible = true
				modules.visible = true
				weapon_upgrades.visible = false
				module_upgrades.visible = false
			"weapon_swap":
				weapons.visible = true
				weapon_upgrades.visible = true
				modules.visible = false
				module_upgrades.visible = false
			"module_swap":
				modules.visible = true
				module_upgrades.visible = true
				weapons.visible = false
				weapon_upgrades.visible = false
	)
