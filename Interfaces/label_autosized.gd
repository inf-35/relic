extends Label

class_name LabelAutosized

@export_enum("autoexpand","determined") var string_size : String = "autoexpand"	
@export var determinant_size : int:
	set(new_determinant):
		determinant_size = new_determinant
		if Engine.is_editor_hint():
			add_theme_font_size_override("font_size",determinant_size)
		

func _ready():
	update_font_size()
	get_viewport().size_changed.connect(update_font_size)

func update_font_size():
	add_theme_font_size_override("font_size",1) 
	update_payload.call_deferred()
	
func update_payload():
	var font_size : int = 1
	var constrained_size : Vector2
	var match_text : String = text
	match string_size:
		"autoexpand":
			constrained_size = size		
			while true:
				var string_size : Vector2 = get_theme_font("font").get_string_size(match_text,horizontal_alignment,-1,font_size)
				font_size += 10
				if (string_size.x > constrained_size.x) or (string_size.y > constrained_size.y):
					break
			while true:
				font_size -= 1
				var string_size : Vector2 = get_theme_font("font").get_string_size(match_text,horizontal_alignment,-1,font_size)
				if (string_size.x <= constrained_size.x) and (string_size.y <= constrained_size.y):
					break
		"determined":
			font_size = floor(determinant_size * ((1920 * 1080) / max((get_viewport_rect().size.x+100) * (get_viewport_rect().size.y+100),0.1)))

	add_theme_font_size_override("font_size",font_size)
