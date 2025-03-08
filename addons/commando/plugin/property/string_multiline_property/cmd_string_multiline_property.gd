## Represents a command property editor for multiline [String] values.
@tool
extends EditorCmdCommandProperty

func _ready() -> void:
	property_editor = $TextEdit as TextEdit
	(property_editor as TextEdit).text_changed.connect(
		func() -> void:
			property_changed.emit(_label.get_text(), property_editor.get_text())
	)


## Sets property value. Value type is [String].
func set_property_value(p_value: String):
	(property_editor as TextEdit).set_text(p_value)
