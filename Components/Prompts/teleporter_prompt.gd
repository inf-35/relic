extends Prompt

class_name TeleporterPrompt

var destination_level : int
var destination_world : String
var destination_level_type : String

func action(actor):
	GameDirector.reset_scene(true)
	GameDirector.create_map(destination_level,destination_world,destination_level_type)
