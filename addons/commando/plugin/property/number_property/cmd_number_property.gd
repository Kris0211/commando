@tool
## Represents a command property editor for numerical ([int]/[float]) values.
class_name EditorCmdNumberProperty extends EditorCmdCommandProperty

var _spin_box: SpinBox = null
var _lambda: Callable = func(value: float) -> void:
			property_changed.emit(_label.get_text(), value)

func _ready() -> void:
	property_editor = $SpinBox
	if property_editor == null:
		printerr("An error occured when creating NumberProperty.")
		return
	
	_spin_box = property_editor as SpinBox
	if _spin_box == null:
		printerr("An error occured when creating NumberProperty.")
		return
	
	_spin_box.value_changed.connect(_lambda)


func _exit_tree() -> void:
	if _spin_box != null  && _spin_box.value_changed.is_connected(_lambda):
		_spin_box.value_changed.disconnect(_lambda)


## Sets property value. Value type is either [int] or [float].
func set_property_value(p_value: Variant) -> void:
	if _spin_box == null:
		return
	
	match typeof(p_value):
		TYPE_INT:
			_spin_box.set_step(1)
			_spin_box.set_use_rounded_values(true)
		TYPE_FLOAT:
			_spin_box.set_step(Cmd.Config.float_step)
			_spin_box.set_use_rounded_values(false)
		_:
			printerr("Cannot assign non-numeric value to NumberProperty!")
			return
	
	_spin_box.set_value_no_signal(p_value)
