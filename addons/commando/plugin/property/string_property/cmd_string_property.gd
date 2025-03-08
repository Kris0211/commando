## Represents a command property editor for [String] values.
@tool
extends EditorCmdCommandProperty

func _ready() -> void:
	property_editor = $LineEdit as LineEdit
	(property_editor as LineEdit).text_changed.connect(
		func(new_text: String) -> void:
			property_changed.emit(_label.get_text(), new_text)
	)


## Sets property value. Value type is [String].
func set_property_value(p_value: String):
	(property_editor as LineEdit).set_text(p_value)
