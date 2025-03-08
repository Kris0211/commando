## Represents a logical comparision between two values 
## (variables or constant values).
## Can be grouped into [ConditionGroup] to be evaluated
## as a chain of conditions.
class_name ConditionData extends Resource

enum ELogicalOperator
{
	AND, ## Boolean 'AND' (&&)
	OR ## Boolean 'OR' (&&)
}

enum EVariableType
{
	VALUE, ## Constant value
	GLOBAL_VARIABLE, ## Global game variable
	LOCAL_VARIABLE ## Local event variable
}

## Logical operator connecting this [ConditionData] with previous one
## when grouped together in [ConditionGroup].
## Not evaluated when only one [ConditionData] is used at a time.
@export var logical_operator := ELogicalOperator.OR

## Type of variable to compare
@export var variable_type := EVariableType.GLOBAL_VARIABLE

## Constant value (or variable identifier) to compare.
@export var variable_name := ""

## Compararison operator to use when evaluating condition
@export_enum(
	"==",
	'!=',
	"<",
	"<=",
	">",
	">="
) var operator: int = OP_EQUAL

## Type of variable to compare previous variable with.
@export var compare_type := EVariableType.VALUE

## Constant value (or variable identifier) to compare previous variable with.
@export var compare_value: String = ""


func evaluate(_context: Object) -> bool:
	var lvalue: Variant = _parse_value(variable_name, variable_type, 
			_context as GameEvent)
	var rvalue: Variant = _parse_value(compare_value, compare_type, 
			_context as GameEvent)
	
	return _evaluate_condition(lvalue, operator, rvalue)


func _parse_value(_variable: String, _type: EVariableType,
		 _event: GameEvent) -> Variant:
	match _type:
		EVariableType.VALUE:
			return _parse_literal(_variable.strip_edges())
		EVariableType.GLOBAL_VARIABLE:
			return _get_global_variable(_variable)
		EVariableType.LOCAL_VARIABLE:
			if _event != null:
				return _event.get_local_event_variable(_variable)
			else:
				printerr("Attempted to fetch a local event variable, \
but no event was provided.")
			return null
		_:
			printerr("Unrecognised variable type in _parse_value(): ", 
					_variable)
			return null


func _parse_literal(literal: String) -> Variant:
	if literal.to_lower() == "true":
		return true
	if literal.to_lower() == "false":
		return false
	
	if literal.is_valid_int():
		return int(literal)
	if literal.is_valid_float():
		return float(literal)
	
	return literal


func _get_global_variable(value_str: String) -> Variant:
	var expr := Expression.new()
	var err := expr.parse(value_str, ["Global"])
	if err != OK:
		printerr("Parse Error: ", expr.get_error_text())
		return null
	
	var res: Variant = expr.execute([Global], Global, false)
	if expr.has_execute_failed():
		printerr("Failed to execute expression: ", expr.get_error_text())
		return null
	
	return res


func _evaluate_condition(left: Variant, op: int, right: Variant) -> bool:
	if left == null || right == null:
		printerr("Evaluation failed: Value is null.")
		return false
	
	match op:
		OP_EQUAL:
			return left == right
		OP_NOT_EQUAL:
			return left != right
		OP_LESS:
			return left < right
		OP_LESS_EQUAL:
			return left <= right
		OP_GREATER:
			return left > right
		OP_GREATER_EQUAL:
			return left >= right
		_:
			return false
