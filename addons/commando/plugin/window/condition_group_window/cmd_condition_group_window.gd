## Condition Group Editor [Window].
## Provides a visual interface for editing conditions
## used by [ConditionBranchCommand] and [LoopCommand].
@tool
class_name EditorCmdConditionGroupWindow extends Window

## Emitted when user clicks on "OK" button.
signal changes_commited(condition_group: ConditionGroup)

const _CONDATA := \
		preload("res://addons/commando/plugin/ui/condition_data/cmd_condition_data.tscn")

var _congroup: ConditionGroup

@onready var _conditions_container := %ConditionGroupContainer as VBoxContainer
@onready var _add_condition_button := %AddConditionButton as Button
@onready var _ok_button := %OkButton as Button
@onready var _cancel_button := %CancelButton as Button


func _ready() -> void:
	_add_condition_button.pressed.connect(_on_add_condition_button_pressed)
	_ok_button.pressed.connect(_on_ok_button_pressed)
	_cancel_button.pressed.connect(_on_cancel_button_pressed)


## Initializes this Condition Group Editor.
func setup(p_widget: EditorCmdCommandWidget) -> void:
	for c in _conditions_container.get_children():
		c.queue_free()
	
	var cmd := p_widget.get_command()
	if !(cmd is ConditionBranchCommand) && !(cmd is LoopCommand):
		return
	
	var condition_group := cmd.condition as ConditionGroup
	if condition_group == null || condition_group.conditions.is_empty():
		# Ensure writeable array
		_congroup = ConditionGroup.new()
		_congroup.conditions = [] 
	else:
		_congroup = condition_group.duplicate(true) as ConditionGroup
		for data: ConditionData in _congroup.conditions:
			_setup_condition_data(data)


func _setup_condition_data(p_data: ConditionData) -> void:
	var condata := _CONDATA.instantiate() as EditorCmdConditionData
	_conditions_container.add_child(condata)
	
	# Disable logical opeartor button for first entry.
	if _conditions_container.get_child_count() == 1:
		condata.logical_operation_button.self_modulate = \
				Color(Color.WHITE, 0.0)
		condata.logical_operation_button.disabled = true
	
	condata.setup(p_data)
	condata.delete_requested.connect(_delete_condition)


func _delete_condition(p_condition: EditorCmdConditionData) -> void:
	var idx := p_condition.get_index()
	_congroup.conditions.remove_at(idx)
	p_condition.queue_free()
	var _update_condata = \
		func() -> void:
			if _conditions_container.get_child_count() == 1:
				_conditions_container.get_child(0).\
						logical_operation_button.set_visible(false)
	_update_condata.call_deferred()


func _on_add_condition_button_pressed() -> void:
	var data := ConditionData.new()
	_congroup.conditions.append(data)
	_setup_condition_data(data)


func _on_ok_button_pressed() -> void:
	changes_commited.emit(_congroup)
	_congroup = null
	close_requested.emit()


func _on_cancel_button_pressed() -> void:
	_congroup = null
	close_requested.emit()
