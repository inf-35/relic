extends Node

const entity_skin_scenes : Dictionary = {
	#regular entities
	"player" : preload("res://Components/EntitySkins/player.tscn"),
	"grunt" : preload("res://Components/EntitySkins/grunt.tscn"),
	"gunner" : preload("res://Components/EntitySkins/gunner.tscn"),
	"beetle" : preload("res://Components/EntitySkins/beetle.tscn"),
	"walker" : preload("res://Components/EntitySkins/walker.tscn"),
	"bomb" : preload("res://Components/EntitySkins/bomb.tscn"),
	"boss" : preload("res://Components/EntitySkins/boss.tscn"),
	#projectiles
	"projectile" : preload("res://Components/EntitySkins/projectile.tscn"),
	#effects
	"explosion" : preload("res://Components/EntitySkins/explosion.tscn"),
	#tiles
	"rock" : preload("res://Components/TileSkins/rock.tscn"),
	#interactables
	"dropped_weapon" : preload("res://Components/InteractableSkins/dropped_weapon.tscn"),
	"health_pickup" : preload("res://Components/InteractableSkins/health_pickup.tscn"),
	"lumen_pickup" : preload("res://Components/InteractableSkins/lumen_pickup.tscn"),
	"teleporter" : preload("res://Components/InteractableSkins/teleporter.tscn"),
	"vending_machine" : preload("res://Components/EntitySkins/vending_machine.tscn"),
	"boss_wall" : preload("res://Components/TileSkins/boss_wall.tscn"),
}
