## Main Dock used by the plugin.
@tool
class_name EditorCmdEventDock extends Container

const _SELETED_EVENT_TEXT := "Selected event: "
const _CMD_WINDOW := \
		preload("res://addons/commando/plugin/window/new_command_window/cmd_new_command_window.tscn")
const _COND_WINDOW := \
		preload("res://addons/commando/plugin/window/condition_group_window/cmd_condition_group_window.tscn")

## Reference to selected event [Node].
static var event_node: GameEvent = null

## Associates category names with their respective command names.
var category_commands_map: Dictionary = {}

## [EditorSelection] for currently edited node
var selection: EditorSelection = null

## [ScriptCreateDialog] used by the editor
var script_create_dialog: ScriptCreateDialog = null


var _window: Window = null
var _selected_widgets: Array[EditorCmdCommandWidget] = []
var _last_selected_widget: Control = null
var _clipboard: Array[Command] = []
var _clipboard_source: GameEvent = null


@onready var _prompt_label := %PromptLabel as Label
@onready var _edit_panel := %EditPanel as PanelContainer
@onready var _selected_event_label := %EventLabel as Label
@onready var _widget_container := %WidgetContainer as EditorCmdWidgetContainer
@onready var _add_command_button := %AddCommandButton as Button


#region ENGINE_CALLBACKS
func _enter_tree() -> void:
	_toggle_editor.call_deferred(false)
	selection = EditorInterface.get_selection()
	selection.selection_changed.connect(_on_node_selected)


func _exit_tree() -> void:
	clear_editor()
	selection.selection_changed.disconnect(_on_node_selected)
	selection = null


func _ready() -> void:
	_widget_container.parent = self
	_scan_commands()


func _input(event: InputEvent) -> void:
	if !_widget_container.is_visible():
		return
	
	var key_event := event as InputEventKey
	if key_event == null:
		return
	
	if key_event.pressed && !key_event.is_echo() && \
			!_selected_widgets.is_empty():
		if key_event.is_ctrl_pressed():
			match key_event.keycode:
				KEY_X:
					cut_selection()
					accept_event()
				KEY_C:
					copy_selection()
					accept_event()
				KEY_V:
					paste_clipboard()
					_deselect_all()
					accept_event()
		elif key_event.keycode == KEY_DELETE:
			_prompt_delete_widgets()
			accept_event()


func _gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	
	if mouse_event.pressed && mouse_event.button_index == MOUSE_BUTTON_LEFT:
		# Deselect all widgets on outside click
		if !_is_click_on_widget(get_viewport().gui_get_focus_owner()):
			_deselect_all()


func _on_focus_exited() -> void:
	for widget: EditorCmdCommandWidget in _selected_widgets:
		if is_instance_valid(widget):
			widget.set_selected(false)
	
	_selected_widgets.clear()
#endregion


#region EDITOR_CONTENT
func populate_editor(p_event_commands: Array[Command]) -> void:
		_widget_container.populate(p_event_commands, self)


func clear_editor() -> void:
	for c in _widget_container.get_children():
		c.call_deferred(&"free")
	_selected_widgets.clear()


func _toggle_editor(p_enabled: bool = true) -> void:
	if _edit_panel != null:
		_edit_panel.visible = p_enabled
	if _prompt_label != null:
		_prompt_label.visible = !p_enabled
#endregion

#region COMMANDS
## Removes a [Command] from event array.
func remove_command(p_command: Command):
	if event_node.event_commands.has(p_command):
		event_node.event_commands.erase(p_command)


func _scan_commands() -> void:
	var _dir := DirAccess.open(Cmd.Config.command_root_dir)
	if _dir == null:
		var err := DirAccess.get_open_error()
		printerr("Failed to open directory '%s' - error code %s: %s" % \
				[Cmd.Config.command_root_dir, err, error_string(err)])
		return
	
	var categories: PackedStringArray = _dir.get_directories()
	var public_categories: PackedStringArray = []
	# Ignore 'private' directories
	for cat: String in categories:
		if cat.begins_with(Cmd.Config.excluded_prefix) || \
				cat in Cmd.Config.excluded_dirs:
			continue
		
		public_categories.append(cat)
	
	# Sort found categories according to category order
	var sorted_categories: PackedStringArray = []
	for cat: String in Cmd.Config.category_order:
		if cat in public_categories:
			sorted_categories.append(cat)
	
	# Add remaining categories
	for cat: String in public_categories:
		if !(cat in sorted_categories):
			sorted_categories.append(cat)
	
	# Associate commands with their categories
	for cat: String in sorted_categories:
		var scripts_path: String = Cmd.Config.command_root_dir + "/" + cat
		var command_scripts: PackedStringArray = \
			DirAccess.get_files_at(scripts_path)
		
		var commands: PackedStringArray = []
		for script: String in command_scripts:
			# Currently only supports GDScript.
			if !script.ends_with(".gd"):
				continue
			
			var command_name := script.get_basename().to_pascal_case()
			commands.append(command_name)
		
		category_commands_map[cat.to_pascal_case()] = commands
#endregion

#region SELECTION
## Callback for widget selection.
func on_widget_selected(p_widget: Control) -> void:
	if !_edit_panel.visible:
		return
	
	var widget = p_widget as EditorCmdCommandWidget
	if widget == null:
		return
	
	# TODO: Implement multiple selection 
	# (currently would deselect other widgets on any operation)
	_select_widget(widget)
	
	_last_selected_widget = widget


func _on_node_selected() -> void:
	clear_editor()
	var selected_nodes: Array[Node] = selection.get_selected_nodes()
	if selected_nodes.size() != 1:
		_toggle_editor(false)
		return
	
	var selected_node := selected_nodes[0]
	event_node = selected_node as GameEvent
	if event_node == null:
		_toggle_editor(false)
		return
	
	_toggle_editor(true)
	_selected_event_label.set_text(_SELETED_EVENT_TEXT + event_node.get_name())
	_widget_container.commands = event_node.event_commands
	populate_editor(event_node.event_commands)


func _select_widget(p_widget: EditorCmdCommandWidget) -> void:
	if p_widget == null || !_edit_panel.visible:
		return
	
	_deselect_all()
	_selected_widgets = [p_widget]
	p_widget.set_selected(true)


func _toggle_selection(p_widget: EditorCmdCommandWidget) -> void:
	if p_widget == null || !_edit_panel.visible:
		return
	
	if _selected_widgets.has(p_widget):
		if is_instance_valid(p_widget):
			p_widget.set_selected(false)
		_selected_widgets.erase(p_widget)
	else:
		if is_instance_valid(p_widget):
			p_widget.set_selected(true)
		_selected_widgets.append(p_widget)


func _deselect_all() -> void:
	if !_edit_panel.visible:
		return
	
	for widget: EditorCmdCommandWidget in _selected_widgets:
		if is_instance_valid(widget):
			widget.set_selected(false)
	_selected_widgets.clear()


func _is_click_on_widget(p_control: Control) -> bool:
	return _widget_container.get_children().has(p_control)
#endregion

#region SCRIPT_CREATE_DIALOG
## Sets a reference to [ScriptCreateDialog] that will be used by this plugin.
func set_script_create_dialog(p_dialog: ScriptCreateDialog) -> void:
	script_create_dialog = p_dialog


## Returns a reference to [ScriptCreateDialog] used by this plugin.
func get_script_create_dialog() -> ScriptCreateDialog:
	return script_create_dialog
#endregion

#region ACTIONS
## Cuts selected widget(s), removing them from the dock 
## and storing them in a clipboard.
func cut_selection() -> void:
	if _selected_widgets.is_empty(): # Nothing to cut
		return
	
	for widget: EditorCmdCommandWidget in _selected_widgets:
		copy_selection()
		var idx := widget.get_index()
		event_node.event_commands.remove_at(idx)
		widget.queue_free()
		_selected_widgets.clear()


## Copies selected widget(s), storing them in a clipboard
## without removing them from the dock.
func copy_selection() -> void:
	if _selected_widgets.is_empty(): # Nothing to copy
		return
	
	for widget: EditorCmdCommandWidget in _selected_widgets:
		_clipboard.clear()
		_clipboard_source = event_node
		var _copied_command := widget.get_command().duplicate(true) as Command
		_clipboard.push_back(_copied_command)


## Pastes the clipboard below selected widget.
## If [param paste_below] is set to [code]false[/code], 
## instead pastes the clipboard above selected widget.
func paste_clipboard(p_paste_below: bool = true) -> void:
	if _clipboard.is_empty(): # Nothing to paste
		return
	
	var target_container: EditorCmdWidgetContainer = _widget_container
	var target_commands: Array[Command] = event_node.event_commands
	var idx := target_commands.size()
	
	if _selected_widgets[0] != null:
		var _paste_target = _selected_widgets[0]
		var _container = _paste_target.get_widget_container()
		if _container != null:
			target_container = _container
			target_commands = _container.commands
		
		idx = _paste_target.get_index() + (1 if p_paste_below else 0)
	
	for cmd: Command in _clipboard:
		var pasted_command := cmd.duplicate(true) as Command
		target_commands.insert(idx, pasted_command)
		
		var _parent_ref = target_container.parent
		if _parent_ref == null:
			_parent_ref = self
		
		var new_widget := target_container.add_command_widget(pasted_command, 
				self, target_container)
		target_container.move_child(new_widget, idx)
		idx += 1


func _prompt_delete_widgets() -> void:
	var _count = _selected_widgets.size()
	var _message: String
	#TODO: Allow deletion of multiple widgets
	if _count == 1:
		_message = "Are you sure you want to delete selected command?"
	else:
		_message = "Are you sure you want to delete {0} commands?"\
				.format([_count])
	
	var _confirmation := CmdUtils.show_confirm_popup(_message, 
			"Please confirm...")
	_confirmation.confirmed.connect(_delete_commands)


func _delete_widget_no_prompt(p_widget: EditorCmdCommandWidget, 
		container: Control = null) -> void:
	if !_selected_widgets.has(p_widget):
		_selected_widgets.append(p_widget)
	_delete_commands()


func _delete_commands() -> void:
	if _selected_widgets.is_empty():
		return
	
	var commands_container := {}
	for widget: EditorCmdCommandWidget in _selected_widgets:
		var cont := widget.get_widget_container()
		if cont == null:
			cont = _widget_container # Fallback to root container
		
		var commands := cont.commands
		if commands == null:
			continue
		
		if !commands_container.has(cont):
			commands_container[cont] = {
				"cmds": commands,
				"indices": []
			}
		commands_container[cont]["indices"].push_back(widget.get_index())
		
	for cont_data in commands_container.values():
		cont_data["indices"].sort_custom(
			func(a: int, b: int) -> bool:
				return a > b
		)
	
	for widget: EditorCmdCommandWidget in _selected_widgets:
		widget.queue_free()
	
	for container in commands_container.keys():
		var cmds: Array[Command] = commands_container[container]["cmds"]
		var indices: Array = commands_container[container]["indices"]
		for i: int in indices:
			cmds.remove_at(i)
		
		for widget: EditorCmdCommandWidget in _selected_widgets:
			if widget.get_widget_container() == container:
				widget.queue_free
	
	_selected_widgets.clear()
#endregion

#region POPUP_WINDOWS
## Callback for "Set Condition" button press.
func on_set_condition_button_pressed(widget: EditorCmdCommandWidget) -> void:
	if _window:
		return
	
	_deselect_all()
	_window = _COND_WINDOW.instantiate() as EditorCmdConditionGroupWindow
	if _window != null:
		add_child(_window)
		_window.close_requested.connect(_destroy_window.bind(widget))
		_window.changes_commited.connect(widget.update_conditions)
		_window.setup(widget)
		_window.popup_centered()


func _on_add_command_button_pressed() -> void:
	if _window: # Do nothing if window is already open
		return
	
	_deselect_all()
	_window = _CMD_WINDOW.instantiate() as EditorNewCommandWindow
	if _window != null:
		_window.scan_requested.connect(_scan_commands)
		add_child(_window)
		_window.close_requested.connect(_destroy_window)
		_window.command_added.connect(_on_command_added)
		_window.populate(category_commands_map)
		_window.popup_centered()


func _on_command_added(p_command: Command) -> void:
	if !event_node.event_commands.is_read_only():
		event_node.event_commands.append(p_command)
	else:
		# Force mutable array and refresh editor to update cache
		selection.clear()
		event_node.event_commands = [p_command]
		EditorInterface.edit_node(event_node)
	
	_widget_container.add_command_widget(p_command, self)
	_destroy_window()


func _destroy_window(p_widget: EditorCmdCommandWidget = null) -> void:
	if p_widget != null && \
			_window.changes_commited.is_connected(p_widget.update_conditions):
		_window.changes_commited.disconnect(p_widget.update_conditions)
	
	_window.free.call_deferred()
	_window = null
#endregion
