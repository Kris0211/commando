## Sets a variable to a random value.
class_name RandomVariableCommand extends Command

enum ERandomMethod
{
	## Uses [method RandomNumberGenerator.randi_range] 
	## to generate a random number
	RANDOM_INT, 
	## Uses [method RandomNumberGenerator.randf_range] 
	## to generate a random number
	RANDOM_FLOAT
}

@export var variable_name: String = ""
@export var mode: ERandomMethod = ERandomMethod.RANDOM_INT
@export var min_value: float = 0.0
@export var max_value: float = 100.0

var _rng := RandomNumberGenerator.new()


func execute(_event: GameEvent) -> void:
	push_error("Cannot execute abstract command.")
	finished.emit()
