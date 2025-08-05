## Represents a command property editor for [bool] values.
@tool
class_name EditorCmdBoolProperty extends EditorCmdCommandProperty

var _check_box: CheckBox = null

var _lambda: Callable = func(toggled_on: bool) -> void:
			property_changed.emit(_label.get_text(), toggled_on)


func _ready() -> void:
	property_editor = $PanelContainer/HBoxContainer/CheckBox
	if property_editor == null:
		printerr("An error occured when creating BoolProperty.")
		return
	
	_check_box = property_editor as CheckBox
	if _check_box == null:
		printerr("An error occured when creating BoolProperty.")
		return
	
	_check_box.toggled.connect(_lambda)


func _exit_tree() -> void:
	if _check_box != null && _check_box.toggled.is_connected(_lambda):
		_check_box.toggled.disconnect(_lambda)


## Sets property value. Value type is [bool].
func set_property_value(p_value: bool):
	if _check_box != null:
		_check_box.set_pressed_no_signal(p_value)
