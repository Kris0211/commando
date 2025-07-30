## A visual representaion of [ConditionData] used by Condition Group editor.
@tool
class_name EditorCmdConditionData extends PanelContainer

## Emitted when user clicks on "X" delete button.
signal delete_requested(condition_data: EditorCmdConditionData)

var _condata: ConditionData

## Reference to logical operation [Button]
@onready var logical_operation_button := \
		%LogicalOperatorButton as OptionButton

## Reference to left-hand variable type [OptionButton]
@onready var left_variable_type_button := \
		%LeftVariableTypeButton as OptionButton

## Reference to left-hand variable value [LineEdit]
@onready var left_variable_value_edit := \
		%LeftVariableValueEdit as LineEdit

## Reference to comparison operator [OptionButton]
@onready var comparison_operator_button := \
		%ComparisonOperatorButton as OptionButton

## Reference to right-hand variable type [OptionButton]
@onready var right_variable_type_button := \
		%RightVariableTypeButton as OptionButton

## Reference to right-hand variable value [LineEdit]
@onready var right_variable_value_edit := \
		%RightVariableValueEdit as LineEdit

## Reference to right-hand boolean [OptionButton][br]
## Only visible if right-hand variable type is "bool"
@onready var variable_boolean := \
		%VariableBoolean as OptionButton

## Reference to the "Delete" [Button]
@onready var delete_button := %DeleteButton as Button


func setup(p_data: ConditionData) -> void:
	_condata = p_data
	
	logical_operation_button.select(p_data.logical_operator)
	left_variable_type_button.select(p_data.variable_type)
	left_variable_value_edit.set_text(p_data.variable_name)
	
	comparison_operator_button.select(p_data.operator)
	right_variable_type_button.select(p_data.compare_type)
	if p_data.compare_type == ConditionData.EVariableType.BOOLEAN:
		_toggle_boolean_dropdown(true)
		variable_boolean.select(int(p_data.compare_value != str(true)))
	else:
		_toggle_boolean_dropdown(false)
		right_variable_value_edit.set_text(p_data.compare_value)


func get_condition_data() -> ConditionData:
	return _condata


func _on_logical_operator_button_item_selected(p_index: int) -> void:
	_condata.logical_operator = p_index


func _on_left_variable_type_button_item_selected(p_index: int) -> void:
	_condata.variable_type = p_index
	if _condata.variable_type == ConditionData.EVariableType.VALUE:
		left_variable_value_edit.placeholder_text = "value"
	elif _condata.variable_type == ConditionData.EVariableType.EXPRESSION:
		left_variable_value_edit.placeholder_text = "expression"
	else:
		left_variable_value_edit.placeholder_text = "name"


func _on_left_variable_value_edit_edited() -> void:
	_condata.variable_name = left_variable_value_edit.get_text()


func _on_comparison_operator_button_item_selected(p_index: int) -> void:
	_condata.operator = p_index


func _on_right_variable_type_button_item_selected(p_index: int) -> void:
	_condata.compare_type = p_index
	if _condata.compare_type == ConditionData.EVariableType.BOOLEAN:
		_toggle_boolean_dropdown(true)
		_condata.compare_value = variable_boolean.get_item_text(
				variable_boolean.get_selected())
		return
	
	_toggle_boolean_dropdown(false)
	if _condata.compare_type == ConditionData.EVariableType.VALUE:
		right_variable_value_edit.placeholder_text = "value"
	elif _condata.compare_type == ConditionData.EVariableType.EXPRESSION:
		right_variable_value_edit.placeholder_text = "expression"
	else:
		right_variable_value_edit.placeholder_text = "name"


func _on_right_variable_value_edit_edited() -> void:
	_condata.compare_value = right_variable_value_edit.get_text()


func _on_variable_boolean_item_selected(index: int) -> void:
	_condata.compare_value = variable_boolean.get_item_text(index)


func _on_delete_button_pressed() -> void:
	delete_requested.emit(self)


func _toggle_boolean_dropdown(toggle: bool) -> void:
	variable_boolean.set_visible(toggle)
	right_variable_value_edit.set_visible(!toggle)
