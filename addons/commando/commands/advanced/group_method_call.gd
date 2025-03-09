class_name GroupMethodCallCommand extends Command

@export var group_name: String = ""
@export var method_name: String = ""
# TODO: Add support for supplying arguments to method.

func execute(_event: GameEvent) -> void:
	if group_name.is_empty() || method_name.is_empty():
		push_error("%s: Unable to call group method." % _event.name)
		finished.emit()
		return
	
	_event.get_tree().call_group(group_name, method_name)
	finished.emit()
