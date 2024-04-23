extends Node

class_name Passive

var player : Player

var activated : bool = false:
	set(new_activation):
		if new_activation:
			activate()
		else:
			deactivate()
		activated = new_activation
		
var item_texture : Texture  #texture used for ui icon
var data_name : String = "undefined"
var proper_name : String = "undefined" #TODO : implement localisation
var description : String = "undefined"
	
func setup_stats():
	pass 
	
func _init():
	setup_stats()
	
func activate():
	push_error(str(self), " passive behaviour undefined.")
	
func deactivate():
	push_error(str(self), " passive behaviour undefined.")
