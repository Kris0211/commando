@tool
extends EditorCmdCommandProperty

func _ready() -> void:
	property_editor = $SpinBox as SpinBox
	(property_editor as SpinBox).value_changed.connect(
		func(value: float) -> void:
			property_changed.emit(_label.get_text(), value)
	)


func set_property_value(p_value: Variant) -> void:
	match typeof(p_value):
		TYPE_INT:
			(property_editor as SpinBox).set_step(1)
			(property_editor as SpinBox).set_use_rounded_values(true)
		TYPE_FLOAT:
			(property_editor as SpinBox).set_step(Cmd.Config.float_step)
			(property_editor as SpinBox).set_use_rounded_values(false)
		_:
			printerr("Cannot assign non-numeric value to NumberProperty")
			return
	(property_editor as SpinBox).set_value_no_signal(p_value)
