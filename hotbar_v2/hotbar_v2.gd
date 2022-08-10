extends Control

var UIExtra = preload("res://godot-libs/libs/utils/ui_extra.gd")
var ObjectUtils = preload("res://godot-libs/libs/utils/object_utils.gd")

export(int) var length:int = 0 setget set_length, get_length

onready var cells_manager = $CellsManager \
		setget set_cells_manager, get_cells_manager

var debug = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if(debug):
		print("HotbarV2 -> _ready():")
	var cm = cells_manager
	
	if(debug):
		print("Length: ", length)
		print("Setting length")
	ObjectUtils.set_info(
		cm,
		{
			"debug": debug,
			"can_grab_focus": true,
			"length": length,
		})
	if(debug):
		print("Restoring focus: ")
	
	cm.restore_focus()
	
	if(debug):
		print("Cells manager length: ", cm.length)
		print("Cells manager type: ", typeof(cm))
	
	# Changing the size and the anchors
	UIExtra.set_hotbar_panel_anchors({
			"info": {
				"cells_min_size": cm.cells_min_size,
				"debug": debug,
				"grid_container": cm,
				"length": cm.length,
			}
		})
	cm.update_cells_size()
	
	UIExtra.set_cells_position({
		"info": {
			"cells": cm.cells,
			"cells_manager": cm,
			"debug": debug,
			"length": cm.length,
		}
	})


func _input(_event):
	cells_manager.middle_mouse_manager()


func set_cells_manager(value) -> void:
	cells_manager = value
func get_cells_manager():
	return cells_manager


func get_inventory_script():
	return cells_manager.inventory
func add_item(dict:Dictionary):
	if(debug):
		print("Hotbarv2 -> add_item_by_id(dict:Dictionary):")
	
	var item_set = get_inventory_script() \
			.add_item_by_dict({
				"info": dict
			})
	
	return item_set

func set_length(value:int) -> void:
	length = value
	
	# Update cells_manager length
	if(cells_manager):
		cells_manager["length"] = value
func get_length() -> int:
	return length
