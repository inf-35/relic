extends Node

var entity_skin_scenes : Dictionary = {
	#regular entities
	"player" : load("res://Components/EntitySkins/player.tscn"),
	"grunt" : load("res://Components/EntitySkins/grunt.tscn"),
	"gunner" : load("res://Components/EntitySkins/gunner.tscn"),
	"beetle" : load("res://Components/EntitySkins/beetle.tscn"),
	"walker" : load("res://Components/EntitySkins/walker.tscn"),
	"bomb" : load("res://Components/EntitySkins/bomb.tscn"),
	"boss" : load("res://Components/EntitySkins/boss.tscn"),
	#projectiles
	"basic_projectile" : load("res://Components/ProjectileSkins/basic_projectile.tscn"),
	"homing_projectile" : load("res://Components/ProjectileSkins/homing_projectile.tscn"),
	#effects
	"explosion" : load("res://Components/EntitySkins/explosion.tscn"),
	#tiles
	"rock" : load("res://Components/TileSkins/rock.tscn"),
	#interactables
	"dropped_weapon" : load("res://Components/InteractableSkins/dropped_weapon.tscn"),
	"health_pickup" : load("res://Components/InteractableSkins/health_pickup.tscn"),
	"lumen_pickup" : load("res://Components/InteractableSkins/lumen_pickup.tscn"),
	"teleporter" : load("res://Components/InteractableSkins/teleporter.tscn"),
	"vending_machine" : load("res://Components/EntitySkins/vending_machine.tscn"),
	"boss_wall" : load("res://Components/TileSkins/boss_wall.tscn"),
}
