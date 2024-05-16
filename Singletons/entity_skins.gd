extends Node

const entity_skin_scenes : Dictionary = {
	#regular entities
	"player" : preload("res://Components/EntitySkins/player.tscn"),
	"grunt" : preload("res://Components/EntitySkins/grunt.tscn"),
	"beetle" : preload("res://Components/EntitySkins/beetle.tscn"),
	"boss" : preload("res://Components/EntitySkins/boss.tscn"),
	#projectiles
	"projectile" : preload("res://Components/EntitySkins/projectile.tscn"),
	#tiles
	"rock" : preload("res://Components/TileSkins/rock.tscn"),
	#interactables
	"dropped_weapon" : preload("res://Components/InteractableSkins/dropped_weapon.tscn"),
	"teleporter" : preload("res://Components/InteractableSkins/teleporter.tscn"),
	"vending_machine" : preload("res://Components/EntitySkins/vending_machine.tscn"),
	"boss_wall" : preload("res://Components/TileSkins/boss_wall.tscn"),
}
