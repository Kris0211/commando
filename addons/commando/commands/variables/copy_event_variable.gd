## Copies a Local Event Variable from another event.
class_name CopyEventVariableCommand extends Command

@export_group("World Event", "source_")
## Reference to [GameEvent] to copy Local Event Variable from.
@export_node_path("GameEvent") var source_event: NodePath
## The name of Local Event Variable to copy.
@export var source_variable_name: String

@export_group("Overrides", "override_")
## When enabled, the copied Local Event Variable will be renamed.
@export var override_rename_variable: bool = false
## New Local Event Variable name after copy.
@export var override_new_variable_name: String = ""


func execute(_event: Object) -> void:
	if source_variable_name.is_empty():
		push_error("Variable name cannot be empty.")
		finished.emit()
		return
	
	var other := _event.get_node_or_null(source_event) as GameEvent
	if other == null:
		push_error("Source GameEvent not set.")
		finished.emit()
		return
	
	var new_variable_name := override_new_variable_name \
			if override_rename_variable else source_variable_name
	
	_event.set_local_event_variable(new_variable_name, 
			other.get_local_event_variable(source_variable_name))
	
	finished.emit()
