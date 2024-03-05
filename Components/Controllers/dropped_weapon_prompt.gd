extends Prompt

class_name DroppedWeaponPrompt

@export var weapon_name : String

func action(actor):
	var weapon : Weapon = load("res://Components/Weapons/"+weapon_name+".tscn").instantiate()
	weapon.controller = actor
	actor.weapons.add_child(weapon)
	actor.weapon_dict[1000] = weapon
	await get_tree().create_timer(0.15).timeout
	print("On weapon prompt")
	print(GameDirector.player.weapon_dict)
	GuiDirector.customisation_menu_type = "weapon_swap"
	GuiDirector.customisation_menu_visible = true
	
	get_parent().queue_free()
