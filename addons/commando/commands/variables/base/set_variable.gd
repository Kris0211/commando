## Sets a Global variable to a new value.
class_name SetVariableCommand extends Command

enum EVariableType 
{
	INT, ## Treat value as [int]
	FLOAT, ## Treat value as [float]
	STRING, ## Treat value as [String]
	BOOL, ## Treat value as [bool]
	EXPRESSION, ## Treat value as [Expression] to be evaluated
}

enum EOperationType
{
	SET, ## Corresponds to '=' operator
	ADD, ## Corresponds to '+' operator
	SUBTRACT, ## Corresponds to '-' operator
	MULTIPLY, ## Corresponds to '*' operator
	DIVIDE ## Corresponds to '/' operator
}

## The name of this variable.
@export var variable_name: String
## Value of this variable.
@export var value: String = ""
## Type of this value. Supported types are [int], [float], String] and [bool].
@export var type := EVariableType.STRING
## Operation to perform on the variable. Works if value is a number 
## ([int] or [float])
@export var operation := EOperationType.SET

var _expression := Expression.new()

func execute(_event: GameEvent) -> void:
	push_error("Cannot execute abstract command.")
	finished.emit()
