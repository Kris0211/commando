## Sets a Global variable to a new value.
class_name SetVariableCommand extends Command

enum EVariableType {
	STRING, ## Treat value as [String]
	FLOAT, ## Treat value as [float]
	INT, ## Treat value as [int]
	BOOL, ## Treat value as [bool]
}

enum EOperationType
{
	SET, ## Corresponds to '==' operator
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE
}

## The name of this variable.
@export var variable_name: String
## Value of this variable.
@export var value: String = ""
## Type of this value. Supported types are [String], [float], [int] and [bool].
@export var type := EVariableType.STRING
## Operation to perform on the variable. Works if value is a number 
## ([int] or [float])
@export var operation := EOperationType.SET


func execute(_event: Object) -> void:
	push_error("Cannot execute abstract command.")
	finished.emit()
