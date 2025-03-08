## A widget representing a [ConditionBranchCommand] in GUI dock editor.
@tool
class_name EditorCmdConditionBranchWidget extends EditorCmdCommandWidget

## Emitted when user clicks on "Set condition" button.
signal condition_edit_requested(widget: EditorCmdCommandWidget)

var _is_true_container_collapsed := false
var _is_false_container_collapsed := true

## Reference to [Container] holding widgets associated with "true" branch.
@onready var if_true_container := %IfTrueContainer as EditorCmdWidgetContainer
## Reference to [Container] holding widgets associated with "false" branch.
@onready var if_false_container := %IfFalseContainer as EditorCmdWidgetContainer

@onready var _condition_button := %ConditionButton as Button
@onready var _toggle_true_button := %ToggleTrueButton as Button
@onready var _toggle_false_button := %ToggleFalseButton as Button


func _ready() -> void:
	super()
	if_true_container.parent = self
	if_false_container.parent = self
	_condition_button.pressed.connect(_on_condition_button_pressed)
	_toggle_true_button.pressed.connect(_on_toggle_true_button_pressed)
	_toggle_false_button.pressed.connect(_on_toggle_false_button_pressed)
	_set_commands.call_deferred()


## Updates [ConditionGroup] used by command associated with this widget.
func update_conditions(p_conditions: ConditionGroup) -> void:
	var cmd := get_command() as ConditionBranchCommand
	if cmd != null:
		cmd.condition = p_conditions


func _set_commands() -> void:
	var branch_command := get_command() as ConditionBranchCommand
	if branch_command != null:
		if_true_container.commands = branch_command.commands_if_true
		if_false_container.commands = branch_command.commands_if_false


func _on_toggle_true_button_pressed() -> void:
	_is_true_container_collapsed =! _is_true_container_collapsed
	_toggle_true_button.text = ">" if _is_true_container_collapsed else "v"
	if_true_container.visible = !_is_true_container_collapsed


func _on_toggle_false_button_pressed() -> void:
	_is_false_container_collapsed =! _is_false_container_collapsed
	_toggle_false_button.text = ">" if _is_false_container_collapsed else "v"
	if_false_container.visible = !_is_false_container_collapsed


func _on_condition_button_pressed() -> void:
	condition_edit_requested.emit(self)
