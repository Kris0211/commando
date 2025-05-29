## Represents a command property editor for [bool] values.
@tool
extends EditorCmdCommandProperty

func _ready() -> void:
	property_editor = $PanelContainer/HBoxContainer/CheckBox as CheckBox
	property_editor.toggled.connect(
		func(toggled_on: bool) -> void:
			property_changed.emit(_label.get_text(), toggled_on)
	)


## Sets property value. Value type is [bool].
func set_property_value(p_value: bool):
	property_editor.set_pressed_no_signal(p_value)
