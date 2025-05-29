## Represents a command property editor for [Color] values.
@tool
extends EditorCmdCommandProperty

func _ready() -> void:
	property_editor = $ColorPickerButton as ColorPickerButton
	(property_editor as ColorPickerButton).color_changed.connect(
		func(new_color: Color) -> void:
			property_changed.emit(_label.get_text(), new_color)
	)


## Sets property value. Value type is [Color].
func set_property_value(p_value: Color):
	(property_editor as ColorPickerButton).set_pick_color(p_value)


## Enables or disables alpha channel in color picker.
func toggle_alpha(p_alpha: bool) -> void:
	await ready
	(property_editor as ColorPickerButton).set_edit_alpha(p_alpha)
