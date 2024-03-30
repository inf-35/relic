extends RichTextLabel

class_name LabelAutosized

var last_font_size : int = 10

@export_enum("autoexpand","determined") var string_size : String = "determined"

func _ready():
	update_font_size()
	get_viewport().size_changed.connect(update_font_size)
	
func update_font_size():
	last_font_size = get_theme_font_size("normal_font_size")
	add_theme_font_size_override("normal_font_size",1)
	
	await get_tree().create_timer(0.01).timeout #await two frames
	update_payload.call_deferred()
	
func update_payload():
	var font_size : int = 1
	var constrained_size : Vector2
	var match_text : String = text
	match string_size:
		"autoexpand":
			constrained_size = size		
			while true:
				font_size += 1
				var string_size : Vector2 = get_theme_font("normal_font").get_string_size(text,HORIZONTAL_ALIGNMENT_CENTER,-1,font_size)
				if (string_size.x > constrained_size.x) or (string_size.y > constrained_size.y) :
					font_size -= 1
					break
				if font_size > 500:
					print(font_size)
					print("EXCEPTION!")
					font_size = last_font_size
					break
					
	add_theme_font_size_override("normal_font_size",font_size)
