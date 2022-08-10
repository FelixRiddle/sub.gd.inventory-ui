extends TextureButton
class_name CellV2

# Objectives:
# [] Second click on an item shows some options
#   [] Lock/Unlock item
#   [] See details
#   [] Drop item
#   [] Move
#     [] Right
#     [] Down
#     [] Left
#     [] Up

signal updated

var debug:bool = false
var updated:bool = false setget set_updated, get_updated

func _ready():
	if(rect_min_size.x <= 0.01 || rect_min_size.y <= 0.01 && get_viewport()):
		var five_percent_viewport = get_viewport().size.x * .05
		rect_min_size = Vector2(five_percent_viewport, five_percent_viewport)
		#print("Min rect size changed, new min_rect_size: ", rect_min_size)


func set_item(item):
	set_item_amount(item["item_amount"])
	set_item_image(item["item_image"])
	update_item_image_size()

# Set and get amount item label
func set_item_amount(value:int) -> void:
	if(debug):
		print("CellV2 -> set_item_amount(value):")
	if(value > 1):
		var label:Label = get_amount_label()
		label.text = String(value)
func get_item_amount() -> int:
	var label:Label = get_amount_label()
	return int(label.text)


func get_amount_label():
	return $Amount


# setget item_image
func set_item_image(value) -> void:
	if(debug):
		print("CellV2 -> set_item_image(value):")
	
	if(typeof(value) == TYPE_STRING):
		value = load(value)
	
	if(value is Texture):
		var texture_rect:TextureRect = get_item_image_node()
		texture_rect.set_texture(value)
func get_item_image():
	var texture_rect:TextureRect = get_item_image_node()
	return texture_rect.get_texture()


func get_item_image_node():
	return $ItemImage


# setget updated
func set_updated(value:bool) -> void:
	updated = value
	
	if(self.updated):
		emit_signal("updated")
func get_updated() -> bool:
	return updated


func update_item_image_size():
	var item_image = $ItemImage
	
	var space = UIExtra.space_between_cells()
	var ms = self.rect_min_size
	var new_size = Vector2(ms.x - space, ms.y - space)
	item_image.rect_min_size = new_size
	item_image.rect_size = new_size


# Notifications
func _notification(what):
	# TODO: Cell actions when the cursor moves around the cells
	match what:
		NOTIFICATION_MOUSE_ENTER: # Mouse entered the area of this control.
			# Show item description
			
			pass
		NOTIFICATION_MOUSE_EXIT: # Mouse exited the area of this control.
			# Hide item description
			
			pass
		NOTIFICATION_FOCUS_ENTER:
			pass # Control gained focus.
		NOTIFICATION_FOCUS_EXIT:
			pass # Control lost focus.
		NOTIFICATION_THEME_CHANGED:
			pass # Theme used to draw the control changed;
			# update and redraw is recommended if using a theme.
		NOTIFICATION_VISIBILITY_CHANGED:
			pass # Control became visible/invisible;
			# check new status with is_visible().
		NOTIFICATION_RESIZED:
			pass # Control changed size; check new size
			# with get_size().
		NOTIFICATION_MODAL_CLOSE:
			pass # For modal pop-ups, notification
			# that the pop-up was closed.
