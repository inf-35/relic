extends Control

class_name VisibilityManager

@onready var weapons : MarginContainer = get_node("Middle/Weapons")
@onready var modules : MarginContainer = get_node("Middle/Modules")
@onready var weapon_upgrades : UpgradesTab = get_node("Middle/WeaponUpgrades")
@onready var module_upgrades : UpgradesTab = get_node("Middle/ModuleUpgrades")
@onready var swap_separator : UpgradesTab = get_node("Middle/Separator")

# Called when the node enters the scene tree for the first time.
func _ready():
	GuiDirector.customisation_menu_changed.connect(func():
		match GuiDirector.customisation_menu_type:
			"standard":
				weapons.visible = true
				modules.visible = true
				swap_separator.upgrade.visible = false
				weapon_upgrades.visible = false
				module_upgrades.visible = false
				
			"weapon_swap":
				weapon_upgrades.index = 0
				swap_separator.index = 0
				
				weapons.visible = true
				weapon_upgrades.visible = true
				swap_separator.upgrade.visible = true
				modules.visible = false
				module_upgrades.visible = false
				
			"module_swap":
				module_upgrades.index = 0
				swap_separator.index = 0
				
				modules.visible = true
				module_upgrades.visible = true
				swap_separator.upgrade.visible = true
				weapons.visible = false
				weapon_upgrades.visible = false
	)
