## Sets a Local Event Variable to a new value.
class_name SetLocalEventVariable extends Command

enum EVariableType {
	STRING, ## Treat value as [String]
	FLOAT, ## Treat value as [float]
	INT, ## Treat value as [int]
	BOOL, ## Treat value as [bool]
}

## The name of this Local Event Variable.
@export var variable_name: String
## Value of this Local Event Variable.
@export var value: String = ""
## Type of this value. Supported types are [String], [float], [int] and [bool].
@export var type := EVariableType.STRING


func execute(_event: Object) -> void:
	if variable_name.is_empty():
		push_error("Variable name cannot be empty.")
		finished.emit()
		return
	
	match type:
		EVariableType.STRING:
			_event.set_local_event_variable(variable_name, str(value))
		EVariableType.FLOAT:
			if !value.is_valid_float():
				push_warning("Value '%s' is not a valid float." % value)
			_event.set_local_event_variable(variable_name, float(value))
		EVariableType.INT:
			if !value.is_valid_int():
				push_warning("Value '%s' is not a valid int." % value)
			_event.set_local_event_variable(variable_name, int(value))
		EVariableType.BOOL:
			if value == "true":
				_event.set_local_event_variable(variable_name, true)
			elif value == "false":
				_event.set_local_event_variable(variable_name, false)
			else:
				push_warning("Value '%s' is not a valid bool." % value)
		_:
			push_error("Unsupported value type!")
	
	finished.emit()
