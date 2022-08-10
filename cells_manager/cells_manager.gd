extends Control
class_name CellsManager

var Cell:PackedScene = preload("res://godot-libs/inventory_ui/" + \
		"cells_manager/cell_v2/cell_v2.tscn")
var InventoryScript = preload("res://godot-libs/inventory/inventory.gd")
var ObjectUtils = preload("res://godot-libs/libs/utils/object_utils.gd")

signal cells_changed(old_arr, new_arr)
# Every time overflow changes free the previous ones?
signal overflow_changed(overflow)
signal size_changed(old_size, new_size)

export(bool) var debug:bool = false setget set_debug, get_debug
# The length will likely be overrided
export(int) var length:int = 0 setget set_length, get_length

var can_grab_focus = false setget set_can_grab_focus, get_can_grab_focus
var cells:Array = [] setget set_cells, get_cells
var cells_container = Node.new() setget set_cells_container, \
		get_cells_container
var cells_min_size:float = 0 setget set_cells_min_size, get_cells_min_size
var grid_ref = Node.new() setget set_grid_ref, get_grid_ref
var inventory:Inventory = InventoryScript.new({"debug": self.debug}) \
		setget set_inventory, get_inventory
var node_ref = Node.new() setget set_node_ref, get_node_ref
var overflow:Array setget set_overflow, get_overflow
var prev_focused:int = 0 setget set_prev_focused, get_prev_focused
# Cells size in pixels
var reliable_viewport = Vector2(
		ProjectSettings.get_setting("display/window/size/width"), \
		ProjectSettings.get_setting("display/window/size/height"))

# Constructor
# info is a dictionary containing values for this object properties
func _init(options:Dictionary = { "info": { } }):
	self.cells_min_size = get_default_rect_size()
	
	# Connect inventory changed
	var _connect_result = inventory.connect("inventory_changed", self, \
			"_on_inventory_inventory_changed")
	
	# Set information
	if(typeof(options) == TYPE_DICTIONARY && options.has("info") && \
			typeof(options["info"]) == TYPE_DICTIONARY):
		var options_info = options["info"]
		ObjectUtils.set_info(self, options_info)
		
		if(self.debug):
			print("CellsManager -> _init(options):")
			print("Node set: ", node_ref)
	else:
		print("It won't work without a reference!")


# It first tries to add the cells to grid_ref, if not possible
# it adds the cells on the node_ref
func _add_cells(new_cells:Array, old_cells:Array) -> void:
	if(self.debug):
		print("CellsManager -> _add_cells(cells, old_cells):")
		print("Grid reference: ", grid_ref)
		print("Node reference: ", node_ref)
	
	# Add cells to the scene tree
	for cell in new_cells:
		ObjectUtils.set_info(cell, {
			"updated": true,
			"rect_min_size": Vector2(self.cells_min_size,
					self.cells_min_size),
		})
		
		if(grid_ref != null && grid_ref is Control):
			grid_ref.add_child(cell)
		elif(node_ref != null && node_ref is Control):
			node_ref.add_child(cell)
		else: # Add to this very node
			self.add_child(cell)
	
	emit_signal("cells_changed", old_cells, new_cells)


func _update_cells(new_cells:Array) -> void:
	if(self.debug):
		print("CellsManager -> _update_cells(new_cells):")
	
	# This new array, only has the remaining cells
	var old_cells = self.cells.duplicate(true)
	self.cells = new_cells
	
	if(node_ref):
		_add_cells(self.cells, old_cells)
		
		# Grab focus
		if(can_grab_focus):
			restore_focus()
		
		if(debug):
			print("Added cells to the scene!")
	elif(debug):
		print("Reference doesn't exist!: ", node_ref)


# Select one to the right
func select_right_cell():
	var selected_cell = get_selected_cell_index()
	if(selected_cell == null):
		return
	
	# Select one to the right
	selected_cell += 1
	if(selected_cell >= cells.size()):
		selected_cell = 0
	
	var new_cell = cells[selected_cell]
	if(self.cell_type == 1):
		new_cell.get_node("TextureButton").grab_focus()
	elif(self.cell_type == 2):
		new_cell.grab_focus()


# Select one to the left
func select_left_cell():
	var selected_cell = get_selected_cell_index()
	if(selected_cell == null):
		return
	
	# Select a cell one to the left
	selected_cell -= 1
	if(selected_cell < 0):
		# selected_cell will be the last index
		selected_cell = cells.size() - 1
	
	var new_cell = cells[selected_cell]
	if(self.cell_type == 1):
		new_cell.get_node("TextureButton").grab_focus()
	elif(self.cell_type == 2):
		new_cell.grab_focus()


# Actions for the middle mouse, to be executed inside an infinite function
# like _physics_process
func middle_mouse_manager() -> void:
	#	● BUTTON_WHEEL_UP = 4
	#	Mouse wheel up.
	#	● BUTTON_WHEEL_DOWN = 5
	#	Mouse wheel down.
	#	● BUTTON_WHEEL_LEFT = 6
	#	Mouse wheel left button (only present on some mice).
	#	● BUTTON_WHEEL_RIGHT = 7
	#	Mouse wheel right button (only present on some mice).
	var wheel_up = Input.is_mouse_button_pressed(BUTTON_WHEEL_UP) || \
			Input.is_joy_button_pressed(0, JOY_DPAD_UP)
	var wheel_down = Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN) || \
			Input.is_joy_button_pressed(0, JOY_DPAD_DOWN)
	
	# The default behaviour of a grid is to handle arrow keys so if we,
	# activate the dpad left and right, it will move with a step of 2
	var wheel_left = Input.is_mouse_button_pressed(BUTTON_WHEEL_LEFT) \
#			|| Input.is_joy_button_pressed(0, JOY_DPAD_LEFT)
	var wheel_right = Input.is_mouse_button_pressed(BUTTON_WHEEL_RIGHT) \
#			|| Input.is_joy_button_pressed(0, JOY_DPAD_RIGHT)
	
	if(wheel_up || wheel_right):
		select_right_cell()
	elif(wheel_down || wheel_left):
		select_left_cell()


func get_selected_cell():
	for cell in cells:
		# We need the texture button state
		var tb:TextureButton = cell.get_node("TextureButton")
		if(tb.has_focus()):
			if(self.debug):
				print("Cell ", cell.name, " has focus.")
			return cell
	return null


func get_selected_cell_index():
	for i in range(cells.size()):
		if(self.cell_type == 1):
			# We need the texture button state
			var tb:TextureButton = cells[i].get_node("TextureButton")
			if(tb.has_focus()):
				return i
		elif(self.cell_type == 2):
			# The node is the texture button
			if(cells[i].has_focus()):
				return i
	return null


# Remove previous overflowed cells from the scene tree
func remove_overflow() -> void:
	if(self.debug):
		print("CellsManager -> remove_overflow():")
	
	for i in range(self.overflow.duplicate().size()):
		self.overflow[i].queue_free()


# Grab focus of the given cell
func select_cell(selected_cell) -> void:
	if(selected_cell):
		selected_cell.grab_focus()


func restore_focus() -> void:
	if(self.debug):
		print("CellsManager -> restore_focus():")
		print("Prev focused: ", self.prev_focused)
	
	if(!can_grab_focus):
		return
	
	if(self.prev_focused < cells.size()):
		var selected_cell = self.cells[self.prev_focused]
		
		select_cell(selected_cell)
	elif(self.cells.size() >= 1):
		var selected_cell = self.cells[0]
		
		select_cell(selected_cell)


# setget can_grab_focus
func set_can_grab_focus(value:bool) -> void:
	can_grab_focus = value
func get_can_grab_focus() -> bool:
	return can_grab_focus


# setget cells
func set_cells(value:Array) -> void:
	cells = value
func get_cells() -> Array:
	return cells


func update_cells_size():
	# Change every cell size
	if(debug):
		print("CellsManager -> update_cells_size():")
		print("Resizing every cell")
	
	for cell in self.cells:
		if(cell.get("rect_min_size")):
			
			# Set rect size
			cell.rect_size = Vector2(
					self.cells_min_size, self.cells_min_size)
			
			# Set rect min size
			cell.rect_min_size = Vector2(
					self.cells_min_size, self.cells_min_size)


func set_cells_container(node_path:String) -> void:
	cells_container = get_node(node_path)
func get_cells_container():
	return cells_container


# setget min_size
func set_cells_min_size(value:float) -> void:
	if(self.debug):
		print("CellsManager -> set_cells_min_size:")
		print("Set cells min size: ", value)
	cells_min_size = value
	
	update_cells_size()
func get_cells_min_size() -> float:
	return cells_min_size


# Set cell textures
func set_cells_textures(textures:Dictionary) -> bool:
	if(debug):
		print("CellsManager -> set_cells_textures():")
	
	var props_name:Array = ["texture_normal", "texture_disabled",
			"texture_focused", "texture_hover", "texture_pressed"]
	
	for cell in self.cells:
		if(cell.get("texture_button")):
			var texture_button = cell.texture_button
			
			# TODO: Maybe use ObjectUtils.set_info()?
			for prop in props_name:
				if(texture_button.get(prop) && textures.has(prop) && \
						textures[prop] is StreamTexture):
					texture_button[prop] = textures[prop]
	
	return true
func change_cells_textures(textures:Dictionary) -> bool:
	return set_cells_textures(textures)
func change_cells_sprites(textures:Dictionary) -> bool:
	return set_cells_textures(textures)


# Get the default rect size, which will be a 5% of the window width
func get_default_rect_size() -> float:
	var new_size:float = reliable_viewport.x * 0.05
	return new_size


# setget debug
func set_debug(value:bool, recursive:bool=true) -> void:
	debug = value
	
	# Also set debug for the inventory class
	if(recursive):
		inventory.debug = self.debug
func get_debug() -> bool:
	return debug


func set_grid_ref(value) -> void:
	grid_ref = value
func get_grid_ref():
	return grid_ref


func set_inventory(value:Inventory) -> void:
	inventory = value
func get_inventory() -> Inventory:
	return inventory


# setget length
# When shrinking the array, it will store the deleted cells in
# the overflow variable
func set_length(value:int) -> void:
	if(debug):
		print("CellsManager -> set_length:")
	
	# For later use, set updated to false
	for cell in self.cells:
		cell.updated = false
	
	# Update inventory size
	var old_length:int = length
	length = value
	inventory.size = value
	emit_signal("size_changed", old_length, length)
	
	if(debug):
		print("Resizing the array...")
	var result:Dictionary = ArrayUtils.smart_change_length(
			self.cells,
			self.length,
			Cell,
			{
				"debug": self.debug,
			})
	
	if("new_array" in result):
		_update_cells(result["new_array"])
	
	# Remove previous overflow cells from the scene tree
	remove_overflow()
	
	# Set the new overflow
	if(result.has("deleted_items")):
		self.overflow = result["deleted_items"]
		emit_signal("overflow_changed", self.overflow)
func get_length() -> int:
	return length


func set_node_ref(value) -> void:
	if(self.debug):
		print("CellsManager -> set_node_ref(value):")
		print("New node ref: ", value)
	if(value is Node):
		node_ref = value
func get_node_ref():
	return node_ref


func set_prev_focused(value:int) -> void:
	prev_focused = value
func get_prev_focused() -> int:
	return prev_focused


func set_overflow(value:Array) -> void:
	overflow = value
func get_overflow() -> Array:
	return overflow


### Signals
# When there are items added or removed from inventory
func _on_inventory_inventory_changed(old_inv:Dictionary = {},
			new_inv_ref:Dictionary = {}) -> void:
	if(debug):
		print("CellsManager -> _on_inventory_inventory_changed:")
	
	# Update cells images/textures
	for pos in new_inv_ref:
		var item = new_inv_ref[pos]
		var cell = cells[item["item_slot"]]
#		print("Item slot: ", item["item_slot"])
		
		cell.set_item(item)
