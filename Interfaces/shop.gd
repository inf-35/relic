extends Control

class_name ShopMenu

var weighted_item_array : Array = []
var max_items : int = 9 #maximum number of items that can physically fit
var max_items_allowed : int = 3: #maximum number of items allowed by game rules
	set(new_max):
		max_items_allowed = new_max
		stock_shop(max_items_allowed - cur_items)
		
var cur_items : int = 0

var selected_item:
	set(new_selected_item):
		print(new_selected_item)
		selected_item = new_selected_item
		purchase_button.text = "PURCHASE (%s / %s)" % [LootDirector.shop_pool[selected_item.data_name].cost, GameDirector.player.bonds]
		if selected_item is Weapon:
			item_preview.weapon = selected_item
		elif selected_item is Module:
			item_preview.module = selected_item
		

@onready var vending_grid : GridContainer = get_node("Vending/VBoxContainer/PanelContainer/MarginContainer/Vending")
@onready var video_preview : VideoStreamPlayer = get_node("MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VideoStreamPlayer")
@onready var item_preview : ItemBox = get_node("MarginContainer/VBoxContainer/Module")
@onready var preview_button : Button = get_node("MarginContainer/VBoxContainer/Preview")
@onready var purchase_button : Button = get_node("MarginContainer/VBoxContainer/Purchase")

func _ready():
	if not GameDirector.run_active: await GameDirector.run_start
	generate_item_array()
	
	vending_grid.child_entered_tree.connect(func(_child):
		cur_items += 1
	)
	
	vending_grid.child_exiting_tree.connect(func(_child):
		cur_items -= 1
		stock_shop(max_items_allowed - cur_items)
	)
	
	GameDirector.player.bonds_changed.connect(func():
		if not selected_item:
			return
		purchase_button.text = "PURCHASE (%s / %s)" % [LootDirector.shop_pool[selected_item.data_name].cost, GameDirector.player.bonds]
	)
	
	purchase_button.pressed.connect(func(): #purchase fr
		if not selected_item:
			return
			
		if GameDirector.player.bonds < LootDirector.shop_pool[selected_item.data_name].cost:
			return
			
		var dropped_weapon = DroppedWeapon.new()
		dropped_weapon.weapon_name = selected_item.data_name
		dropped_weapon.property_cache.position = GameDirector.player.entity.position
		GameDirector.projectiles.add_child.call_deferred(dropped_weapon)
		GameDirector.player.bonds -= LootDirector.shop_pool[selected_item.data_name].cost
	)
	
	stock_shop(max_items_allowed - cur_items)
	
func generate_item_array():
	weighted_item_array = [] #create weighted item array from loot pool
	for item_name in LootDirector.shop_pool:
		for a in range(LootDirector.shop_pool[item_name].weight):
			weighted_item_array.append(item_name)
			
func clear_shop():
	for child in vending_grid.get_children():
		child.free()
	
func stock_shop(items : int):
	for i in range(items):
		var chosen_item_name
		var chosen_item
		
		if len(weighted_item_array) != 0:
			chosen_item_name = weighted_item_array.pick_random()
			weighted_item_array = weighted_item_array.filter(func(item): return item != chosen_item_name)
		
			if LootDirector.shop_pool[chosen_item_name].type == "weapon":
				chosen_item = load("res://Components/Weapons/"+chosen_item_name+".tscn").instantiate()
			elif LootDirector.shop_pool[chosen_item_name].type == "module":
				chosen_item = load("res://Components/Modules/"+chosen_item_name+".tscn").instantiate()
				
		var vending_item : Control = Control.new()
		vending_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vending_item.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if chosen_item:
			vending_item = preload("res://Interfaces/vending_item.tscn").instantiate()
			vending_item.shop = self
			vending_item.item = chosen_item
			vending_item.get_node("RichTextLabel").text = "[center]"+str(LootDirector.shop_pool[chosen_item_name].cost)
			vending_item.get_node("AspectRatioFixed/Panel/MarginContainer/TextureRect").texture = chosen_item.item_texture
		vending_grid.add_child.call_deferred(vending_item)
		
	for i in range(max_items - cur_items):
		var blank_item : Control = Control.new()
		blank_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		blank_item.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vending_grid.add_child.call_deferred(blank_item)
