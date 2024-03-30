extends Control

class_name VisibilityManager

@onready var customisation_menu : Control = get_node("Middle/Customisation")
@onready var customisation : Control = customisation_menu.get_node("Customisation")
@onready var shop : Control = get_node("Middle/Shop")
@onready var weapons : MarginContainer = customisation.get_node("Weapons")
@onready var modules : MarginContainer = customisation.get_node("Modules")
@onready var weapon_upgrades : UpgradesTab = customisation.get_node("WeaponUpgrades")
@onready var module_upgrades : UpgradesTab = customisation.get_node("ModuleUpgrades")
@onready var swap_separator : UpgradesTab = customisation.get_node("Separator")

@onready var customisation_header : Control = get_node("Top/Customisation")
@onready var shop_header : Control = get_node("Top/Shop")

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	
	GuiDirector.customisation_menu_changed.connect(func():
		match GuiDirector.customisation_menu_type:
			"standard":
				shop.visible = false
				customisation_menu.visible = true
				weapons.visible = true
				modules.visible = true
				swap_separator.upgrade.visible = false
				weapon_upgrades.visible = false
				module_upgrades.visible = false
				
			"weapon_swap":
				weapon_upgrades.index = 0
				swap_separator.index = 0
				
				shop.visible = false
				customisation_menu.visible = true
				weapons.visible = true
				weapon_upgrades.visible = true
				swap_separator.upgrade.visible = true
				modules.visible = false
				module_upgrades.visible = false
				
			"module_swap":
				module_upgrades.index = 0
				swap_separator.index = 0
				
				shop.visible = false
				customisation_menu.visible = true
				modules.visible = true
				module_upgrades.visible = true
				swap_separator.upgrade.visible = true
				weapons.visible = false
				weapon_upgrades.visible = false
				
			"shop":
				shop.visible = true
				customisation_menu.visible = false
	)
