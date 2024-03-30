extends Node

var shop_pool : Dictionary = {
	"basic_weapon" : { #data name
		"type" : "weapon", #weapon, module, perk or boost
		"cost" : 500, #cost in the shop
		"weight" : 10 #probability weight
	},
	"ultra_weapon" : {
		"type" : "weapon",
		"cost" : 2000,
		"weight" : 2
	}
}
