extends RichTextLabel

class_name LabelAutosized

var last_font_size : int = 10

@export_enum("autoexpand","bounded") var string_size : String = "autoexpand"
@export var upper_bound : int

func _ready():
	setup()

func setup():
	scroll_active = false
	update_font_size()
	get_viewport().size_changed.connect(update_font_size)
	finished.connect(update_font_size)
	item_rect_changed.connect(update_font_size)
	
func update_font_size():
	last_font_size = get_theme_font_size("normal_font_size")
	add_theme_font_size_override("normal_font_size",1)

	update_payload.call_deferred()
	
func update_payload():
	var font_size : int = 1
	var constrained_size : Vector2
	var match_text : String = get_parsed_text()
	match string_size:
		"autoexpand":
			constrained_size = size		
			while true:
				font_size += 1
				var string_size : Vector2 = get_theme_font("normal_font").get_string_size(match_text,HORIZONTAL_ALIGNMENT_CENTER,-1,font_size)
				var number_of_lines : int = floor(constrained_size.y / string_size.y)
				if ((string_size.x / number_of_lines) > constrained_size.x) or (number_of_lines < 1) :
					font_size -= 1
					break
				if font_size > 500:
					font_size = last_font_size
					break
		"bounded":
			constrained_size = size
			while true:
				font_size += 1
				var string_size : Vector2 = get_theme_font("normal_font").get_string_size(match_text,HORIZONTAL_ALIGNMENT_CENTER,-1,font_size)
				var number_of_lines : int = floor(constrained_size.y / string_size.y)
				if ((string_size.x / number_of_lines) > constrained_size.x) or (number_of_lines < 1) :
					font_size -= 1
					break
				if font_size > upper_bound:
					font_size = upper_bound
					break
				if font_size > 500:
					font_size = last_font_size
					break
					
	add_theme_font_size_override("normal_font_size",font_size)
