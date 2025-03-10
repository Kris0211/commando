## Sets a Local Event Variable to a new value.
class_name SetLocalEventVariableCommand extends SetVariableCommand


func execute(_event: GameEvent) -> void:
	if variable_name.is_empty():
		push_error("%s: Variable name cannot be empty." % _event.name)
		finished.emit()
		return
	
	match type:
		EVariableType.STRING:
			_event.set_local_event_variable(variable_name, str(value))
		EVariableType.FLOAT:
			if !value.is_valid_float():
				push_warning("Value '%s' is not a valid float." % value)
			_change_value(variable_name, float(value), _event)
		EVariableType.INT:
			if !value.is_valid_int():
				push_warning("Value '%s' is not a valid int." % value)
			_change_value(variable_name, int(value), _event)
		EVariableType.BOOL:
			if value == "true":
				_event.set_local_event_variable(variable_name, true)
			elif value == "false":
				_event.set_local_event_variable(variable_name, false)
			else:
				push_warning("Value '%s' is not a valid bool." % value)
		EVariableType.EXPRESSION:
			var err := _expression.parse(value)
			if err != OK:
				push_error("%s: Failed to parse expression %s: %s" %\
						[_event.name, value, _expression.get_error_text()])
				finished.emit()
				return
			
			var new_value = _expression.execute()
			if _expression.has_execute_failed():
				push_error("%s: Failed to execute expression: %s" %\
						[_event.name, _expression.get_error_text()])
				finished.emit()
				return
			
			_change_value(variable_name, new_value, _event)
		_:
			push_error("Unsupported value type!")
	
	finished.emit()


func _change_value(variable_name: String, new_value: Variant,
		_event: GameEvent) -> void:
	if typeof(new_value) == TYPE_INT || typeof(new_value) == TYPE_FLOAT:
		var value = _event.get_local_event_variable(variable_name)
		match operation:
			EOperationType.SET:
				_event.set_local_event_variable(variable_name, value)
				return
			EOperationType.ADD:
				if value != null:
					value += new_value
			EOperationType.SUBTRACT:
				if value != null:
					value -= new_value
			EOperationType.MULTIPLY:
				if value != null:
					value *= new_value
			EOperationType.DIVIDE:
				if value != null:
					value /= new_value
		if value != null:
			_event.set_local_event_variable(variable_name, value)
