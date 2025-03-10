## Sets a Local Event Variable to a random value.
class_name RandomLocalEventVariableCommand extends RandomVariableCommand


func execute(_event: GameEvent) -> void:
	if variable_name.is_empty():
		push_error("%s: Variable name cannot be empty." % _event.name)
		finished.emit()
		return
	
	var random_value
	match mode:
		ERandomMethod.RANDOM_INT:
			random_value = _rng.randi_range(int(min_value), int(max_value))
		ERandomMethod.RANDOM_FLOAT:
			random_value = _rng.randf_range(min_value, max_value)
		_:
			push_error("%s: Undefined random number generation method!")
			finished.emit()
			return
	
	_event.set_local_event_variable(variable_name, random_value)
	finished.emit()
