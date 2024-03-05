extends Controller

class_name DroppedWeapon

var weapon_name : String = ""

func _ready():
	skin = "dropped_weapon"
	
	print("Entered : " + weapon_name)
	if weapon_name != "":
		entity.get_node("DroppedWeaponPrompt").weapon_name = weapon_name
		
	entity.died.connect(func():
		queue_free()
	)
	


