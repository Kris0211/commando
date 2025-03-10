## Sets a target node variable to a random value.
class_name RandomNodeVariableCommand extends RandomVariableCommand

@export_node_path("Node") var target_node: NodePath

func execute(_event: GameEvent) -> void:
	if variable_name.is_empty():
		push_error("%s: Variable name cannot be empty." % _event.name)
		finished.emit()
		return
	
	if target_node.is_empty():
		push_error("%s: Target node not set." % _event.name)
		finished.emit()
		return
	
	var _node := _event.get_node(target_node) as Node
	if _node == null:
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
	
	_node.set(variable_name, random_value)
	finished.emit()
