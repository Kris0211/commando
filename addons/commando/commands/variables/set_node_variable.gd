## Sets a target node variable to a new value.
class_name SetNodeVariableCommand extends SetVariableCommand

@export_node_path("Node") var target_node: NodePath

func execute(_event: Object) -> void:
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
	
	match type:
		EVariableType.STRING:
			_node.set(variable_name, str(value))
		EVariableType.FLOAT:
			if !value.is_valid_float():
				push_warning("Value '%s' is not a valid float." % value)
			_change_value(variable_name, float(value), _node)
		EVariableType.INT:
			if !value.is_valid_int():
				push_warning("Value '%s' is not a valid int." % value)
			_change_value(variable_name, int(value), _node)
		EVariableType.BOOL:
			if value == "true":
				_node.set(variable_name, true)
			elif value == "false":
				_node.set(variable_name, false)
			else:
				push_warning("Value '%s' is not a valid bool." % value)
		_:
			push_error("Unsupported value type!")
	
	finished.emit()


func _change_value(variable_name: String, new_value: Variant,
		node: Node) -> void:
	if typeof(new_value) == TYPE_INT || typeof(new_value) == TYPE_FLOAT:
		var value = node.get(variable_name)
		match operation:
			EOperationType.SET:
				node.set(variable_name, new_value)
				return
			EOperationType.ADD:
				value += new_value
			EOperationType.SUBTRACT:
				value -= new_value
			EOperationType.MULTIPLY:
				value *= new_value
			EOperationType.DIVIDE:
				value /= new_value
		node.set(variable_name, value)
