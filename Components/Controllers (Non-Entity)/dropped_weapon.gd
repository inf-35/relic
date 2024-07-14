extends Controller

class_name DroppedWeapon

var weapon_name : String = ""
var passive_name : String = ""

func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
		
	skin = "dropped_weapon"
	
	if weapon_name != "":
		entity.get_node("DroppedWeaponPrompt").weapon_name = weapon_name
		
	entity.died.connect(func():
		queue_free()
	)
	


