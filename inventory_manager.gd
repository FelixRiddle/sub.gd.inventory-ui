extends CanvasLayer
class_name InventoryManager

signal inventory_added(added_inv)

# The length will likely be overrided
export(bool) var debug:bool = false setget set_debug, get_debug

var ObjectUtils = preload("res://godot-libs/libs/utils/object_utils.gd")

func _init():
	if(debug):
		print("InventoryManager -> _init:")
	
	# Connect to the cells changed for instancing and destroying cells
	var _connect_result = connect(
			"cells_changed", self, "_on_inventory_manager_cells_changed")


# setget debug
func set_debug(value:bool) -> void:
	debug = value
func get_debug() -> bool:
	return debug
