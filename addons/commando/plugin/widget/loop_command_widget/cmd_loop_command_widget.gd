## A widget representing a [LoopCommand] in GUI dock editor.
@tool
class_name EditorCmdLoopCommandWidget extends EditorCmdCommandWidget

## Emitted when user clicks on "Set condition" button.
signal condition_edit_requested(widget: EditorCmdCommandWidget)

var _is_container_collapsed := false

## Reference to [Container] holding widgets associated with looping commands.
@onready var loop_container := %LoopContainer as EditorCmdWidgetContainer

@onready var _condition_button := %ConditionButton as Button
@onready var _toggle_button := %ToggleButton as Button


func _ready() -> void:
	super()
	loop_container.parent = self
	_condition_button.pressed.connect(_on_condition_button_pressed)
	_toggle_button.pressed.connect(_on_toggle_button_pressed)
	_set_commands.call_deferred()


## Updates [ConditionGroup] used by command associated with this widget.
func update_conditions(p_conditions: ConditionGroup) -> void:
	var cmd := get_command() as LoopCommand
	if cmd != null:
		cmd.condition = p_conditions


func _set_commands() -> void:
	var cmds := (get_command() as LoopCommand)
	if cmds != null:
		loop_container.commands = cmds.commands


func _on_toggle_button_pressed() -> void:
	_is_container_collapsed = !_is_container_collapsed
	_toggle_button.text = ">" if _is_container_collapsed else "v"
	loop_container.visible = !_is_container_collapsed


func _on_condition_button_pressed() -> void:
	condition_edit_requested.emit(self)
