extends Prompt

class_name DroppedWeaponPrompt

var weapon_name : String
var passive_name : String

func action(actor):
	if weapon_name != "":
		var weapon : Node = Node.new()
		weapon.set_script(load("res://Components/Weapons/"+weapon_name+".gd"))
		weapon.controller = actor
		actor.weapons.add_child(weapon)
		actor.weapon_dict[1000] = weapon
		await get_tree().create_timer(0.15).timeout
		GuiDirector.customisation_menu_type = "weapon_swap"
		GuiDirector.customisation_menu_visible = true
	elif passive_name != "":
		var passive : Passive = load("res://Components/Passives"+passive_name+".tscn").instantiate()
		passive.controller = actor
		actor.passives.add_child(passive)
		actor.passive_dict[1000] = passive
		await get_tree().create_timer(0.15).timeout
		GuiDirector.customisation_menu_type = "module_swap"
		GuiDirector.customisation_menu_visible = true
		
	get_parent().queue_free()
