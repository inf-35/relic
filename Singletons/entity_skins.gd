extends Node

var entity_skin_scenes : Dictionary = {
	#regular entities
	"circle" : preload("res://Components/EntitySkins/player.tscn"),
	"grunt" : preload("res://Components/EntitySkins/grunt.tscn"),
	"beetle" : preload("res://Components/EntitySkins/beetle.tscn"),
	#tiles
	"rock" : preload("res://Components/TileSkins/rock.tscn"),
	#interactables
	"dropped_weapon" : preload("res://Components/InteractableSkins/dropped_weapon.tscn"),
	"teleporter" : preload("res://Components/InteractableSkins/teleporter.tscn")
}
