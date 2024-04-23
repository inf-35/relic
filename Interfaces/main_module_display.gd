extends VBoxContainer

class_name MainModuleDisplay
@export var module_slot : int = 0

@onready var weapon_display : TextureRect = get_node("AspectRatioContainer/TextureRect")
@onready var title : RichTextLabel  = get_node("Title")
@onready var subheader : RichTextLabel = get_node("Subheader")
@onready var description : RichTextLabel = get_node("Description")

@onready var binary_one : PanelContainer = get_node("Binary/AspectRatioFixed/One")
@onready var binary_two : PanelContainer = get_node("Binary/AspectRatioFixed2/Two")
@onready var binary_three : PanelContainer = get_node("Binary/AspectRatioFixed3/Three")

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
		
	update()
	GameDirector.player.weapon_update.connect(update)

func update():
	if GameDirector.player.weapon_dict.has(module_slot) and GameDirector.player.weapon_dict[module_slot] is Weapon:
		var module : Weapon = GameDirector.player.weapon_dict[module_slot]
		print(module)
		title.text = module.proper_name + " [i]v.1.0[/i]"
		weapon_display.texture = module.item_texture
		description.text = module.description
	
	binary_one.visible = (module_slot > 3)
	binary_two.visible = ((module_slot % 4) > 1)
	binary_three.visible = ((module_slot % 2) == 1)
	
