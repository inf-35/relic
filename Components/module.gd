extends Node

class_name Module

var player : Player

var activated : bool = false:
	set(new_activation):
		if new_activation:
			activate()
		else:
			deactivate()
		activated = new_activation
		
var item_texture : Texture  #texture used for ui icon
var proper_name : String = "undefined" #TODO : implement localisation
var description : String = "undefined"
	
func activate():
	push_error(str(self), " module behaviour undefined.")
	
func deactivate():
	push_error(str(self), " module behaviour undefined.")
