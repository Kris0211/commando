@tool
extends PanelContainer

## Emitted when clicking on top panel with either left or right mouse button.
signal clicked_on
## Emitted when clicking on top panel with right mouse button, 
## requesting context menu popup.
signal popup_requested

# Relies on scene structure - may break!
@onready var parent_widget := $"../.." as EditorCmdCommandWidget


func _gui_input(event: InputEvent) -> void:
	var _mouse_event := event as InputEventMouseButton
	if _mouse_event == null:
		return
	
	if _mouse_event.pressed:
		if _mouse_event.button_index == MOUSE_BUTTON_LEFT:
			clicked_on.emit()
		elif _mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			clicked_on.emit()
			popup_requested.emit()


func _get_drag_data(_at_position: Vector2) -> Variant:
	assert(parent_widget != null) # Should never happen.
	var preview = self.duplicate()
	preview.modulate = Color(1.0, 1.0, 1.0, 0.5)
	set_drag_preview(preview)
	return parent_widget
