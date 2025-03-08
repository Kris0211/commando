## Base class for all command widget containers 
## (main dock, branches, loops, etc.)
@tool
class_name EditorCmdWidgetContainer extends VBoxContainer

const _WIDGET := \
		preload("res://addons/commando/plugin/widget/command_widget/cmd_command_widget.tscn")
const _CONDITION_BRANCH_WIDGET := \
		preload("res://addons/commando/plugin/widget/condition_branch_widget/cmd_condition_branch_widget.tscn")
const _CUSTOM_COMMAND_WIDGET := \
		preload("res://addons/commando/plugin/widget/custom_command_widget/cmd_custom_command_widget.tscn")
const _LOOP_COMMAND_WIDGET := \
		preload("res://addons/commando/plugin/widget/loop_command_widget/cmd_loop_command_widget.tscn")

## A [Control] that contains this widget container.
## Can either be a widget or plugin's root dock.
var parent: Control
## An [Array] of [Command]s associated with widgets 
## inside this widget container.
var commands: Array[Command]


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is EditorCmdCommandWidget


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if !(data is EditorCmdCommandWidget):
		return
	
	var widget := data as EditorCmdCommandWidget
	if data == parent || data.is_ancestor_of(parent):
		return
	
	widget.disconnect_signals()
	var command := widget.get_command()
	
	var widget_parent = widget.get_parent() as EditorCmdWidgetContainer
	if widget_parent != null:
		widget_parent.remove_child(widget)
		widget_parent.remove_command(command)
	
	var drop_index := _get_drop_index(at_position)
	add_child(widget)
	move_child(widget, drop_index)
	widget.reconnect(self)
	if commands != null:
		commands.insert(clamp(drop_index, 0, commands.size()), command)


## Reads the command array and instantiates widgets accordingly.
func populate(
		p_commands: Array[Command], 
		p_dock: EditorCmdEventDock, 
		p_parent: Control = self
) -> void:
	commands = p_commands
	for cmd: Command in commands:
		add_command_widget(cmd, p_dock, p_parent)


## Adds a command widget to this container.
func add_command_widget(
		p_command: Command, 
		p_dock: EditorCmdEventDock, 
		p_parent: Control = self
) -> EditorCmdCommandWidget:
	var command_widget: EditorCmdCommandWidget
	if p_command is CustomCommand:
		command_widget = _CUSTOM_COMMAND_WIDGET.instantiate() \
				as EditorCmdCustomCommandWidget
	elif p_command is ConditionBranchCommand:
		command_widget = _CONDITION_BRANCH_WIDGET.instantiate() \
				as EditorCmdConditionBranchWidget
	elif p_command is LoopCommand:
		command_widget = _LOOP_COMMAND_WIDGET.instantiate() \
				as EditorCmdLoopCommandWidget
	else:
		command_widget = _WIDGET.instantiate() as EditorCmdCommandWidget
	
	if command_widget != null:
		add_child(command_widget)
		command_widget.setup(p_command, p_dock, p_parent)
		command_widget.cut_requested.connect(p_dock.cut_selection)
		command_widget.copy_requested.connect(p_dock.copy_selection)
		command_widget.paste_requested.connect(p_dock.paste_clipboard)
		command_widget.delete_requested.connect(p_dock._delete_widget_no_prompt)
	
	if command_widget is EditorCmdConditionBranchWidget:
		command_widget.condition_edit_requested.connect(
				command_widget.get_dock().on_set_condition_button_pressed)
		var cmd := p_command as ConditionBranchCommand
		command_widget.if_true_container.populate(cmd.commands_if_true, 
				p_dock, command_widget.if_true_container)
		command_widget.if_false_container.populate(cmd.commands_if_false, 
				p_dock, command_widget.if_false_container)
	if command_widget is EditorCmdLoopCommandWidget:
		command_widget.condition_edit_requested.connect(
				command_widget.get_dock().on_set_condition_button_pressed)
		var cmd := p_command as LoopCommand
		command_widget.loop_container.populate(cmd.commands, 
				p_dock, command_widget.loop_container)
	
	return command_widget


## Removes a [Command] from command array.
func remove_command(p_command: Command):
	if commands.has(p_command):
		commands.erase(p_command)


## Return a widget containing this container.
## Returns [code]null[/code] if this is a root container 
## (child of [EditorCmdEventDock]).
func get_parent_widget() -> EditorCmdCommandWidget:
	return parent as EditorCmdCommandWidget


func _get_drop_index(p_position: Vector2) -> int:
	var index: int = 0
	var local_pos := p_position
	
	var _parent_control := get_parent()
	if _parent_control is ScrollContainer:
		local_pos -= Vector2(0, _parent_control.scroll_horizontal)
	
	for i in range(get_child_count()):
		var child := get_child(i) as EditorCmdCommandWidget
		if child == null:
			continue
		
		var rect := Rect2(child.position, child.size)
		if local_pos.y < rect.position.y + rect.size.y * 0.5:
			break
		
		index = i + 1
	
	return index
