## Groups multiple [ConditionData] together
## and evaluates them based on logical operators.
class_name ConditionGroup extends Resource

## All [ConditionData]s to be evaluated.
@export var conditions: Array[ConditionData] = []

## Evaluate all conditions using their assigned logical operators.
func evaluate(_context: Object) -> bool:
	if conditions.is_empty():
		push_warning("No conditions were set, nothing to evaluate!")
		return false
	
	var result: bool = conditions[0].evaluate(_context)
	for i: int in range(1, conditions.size()):
		var condition: ConditionData = conditions[i]
		var cond_result: bool = condition.evaluate(_context)
		match condition.logical_operator:
			ConditionData.ELogicalOperator.AND:
				result = result && cond_result
			ConditionData.ELogicalOperator.OR:
				result = result || cond_result
			_:
				printerr("Undefined logical operator.")
	
	return result
