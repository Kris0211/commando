## Sets a Global variable to a new value.
class_name SetGlobalVariableCommand extends SetVariableCommand


func execute(_event: Object) -> void:
	if variable_name.is_empty():
		push_error("Variable name cannot be empty.")
		finished.emit()
		return
	
	match type:
		EVariableType.STRING:
			Global.set(variable_name, str(value))
		EVariableType.FLOAT:
			if !value.is_valid_float():
				push_warning("Value '%s' is not a valid float." % value)
			_change_value(variable_name, float(value))
		EVariableType.INT:
			if !value.is_valid_int():
				push_warning("Value '%s' is not a valid int." % value)
			_change_value(variable_name, int(value))
		EVariableType.BOOL:
			if value == "true":
				Global.set(variable_name, true)
			elif value == "false":
				Global.set(variable_name, false)
			else:
				push_warning("Value '%s' is not a valid bool." % value)
		_:
			push_error("Unsupported value type!")
	
	finished.emit()


func _change_value(variable_name: String, new_value: Variant) -> void:
	if typeof(new_value) == TYPE_INT || typeof(new_value) == TYPE_FLOAT:
		var value = Global.get(variable_name)
		match operation:
			EOperationType.SET:
				Global.set(variable_name, new_value)
				return
			EOperationType.ADD:
				value += new_value
			EOperationType.SUBTRACT:
				value -= new_value
			EOperationType.MULTIPLY:
				value *= new_value
			EOperationType.DIVIDE:
				value /= new_value
		Global.set(variable_name, value)
