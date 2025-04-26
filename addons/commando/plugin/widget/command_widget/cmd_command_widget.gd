## A widget representing a [Command] in GUI dock editor.
@tool
class_name EditorCmdCommandWidget extends Container

## Emitted when user requests the "Cut" operation.
signal cut_requested
## Emitted when user requests the "Copy" operation.
signal copy_requested
## Emitted when user requests the "Paste Above/Below" operation.
signal paste_requested(paste_below: bool)
## Emitted when user requests deletion of this widget.
signal delete_requested(widget: EditorCmdCommandWidget, container: Control)
## Emitted when user moves this widget inside dock.
signal reorder_requested(widget: EditorCmdCommandWidget, new_index: int)

enum EContextMenuOptions {
	CUT, ## Cut operation
	COPY, ## Copy operation
	PASTE_ABOVE, ## Paste Above operation
	PASTE_BELOW, ## Paste Below operation
	DELETE ## Delete operation
}


## Is this widget currently selected?
var selected: bool = false

var _was_moved: bool = false
var _color: Color
var _command_wref: WeakRef#[Command]
var _editor_dock: WeakRef#[EditorCmdEventDock]
var _container: WeakRef#[EditorCmdWidgetContainer]

@onready var _top_panel := $VBoxContainer/TopPanel as PanelContainer
@onready var _content_panel := $VBoxContainer/ContentPanel as PanelContainer
@onready var _content_container := %ContentContainer as VBoxContainer
@onready var _widget_name := %WidgetName as Label
@onready var _widget_icon := %WidgetIcon as TextureRect

@onready var _context_menu := PopupMenu.new()


func _exit_tree() -> void:
	disconnect_signals()


func _ready() -> void:
	_setup_context_menu()


## Initializes this widget.
func setup(p_command: Command, p_dock: Control, p_container: Container) -> void:
	_command_wref = weakref(p_command)
	_editor_dock = weakref(p_dock)
	_container = weakref(p_container)
	
	# Setup widget
	var command_name: String = _get_command_name(p_command)
	_set_widget_name(command_name.capitalize())
	_set_widget_icon(_get_command_icon(command_name))
	
	# Find widget category
	var cat_name: String = "default"
	var cmdmap := get_dock().category_commands_map
	if cmdmap != null:
		for cat: String in cmdmap.keys():
			if command_name in cmdmap[cat]:
				cat_name = cat.to_snake_case()
				break
	
	# Set widget color according to category
	var _widget_color: Color = Cmd.Config.colors.get(cat_name, 
			Cmd.Config.colors.default)
	_set_widget_color(_widget_color)
	
	# Create properties
	for cproperty: Dictionary in p_command.get_property_list():
		if EditorCmdEventProperties.is_property_exported(cproperty):
			add_property(cproperty, p_command.get(cproperty.get("name")))
	
	# Connect selection signal
	_top_panel.clicked_on.connect(_on_selected)
	_top_panel.popup_requested.connect(_on_context_menu_popup_requested)


## Adds a new [EditorCmdCommandProperty] to this widget.
func add_property(p_property: Dictionary, p_value: Variant) -> void:
	var property := CmdPropertyFactory.create_property(p_property)
	if property == null:
		printerr("Failed to create property for %s!" % p_property)
		return
	
	_content_container.add_child(property)
	property.parent_widget = self
	
	var property_name = p_property.get("name")
	property.set_property_name(property_name)
	property.set_property_value(p_value)
	property.property_changed.connect(_on_property_changed)


## Returns a reference to [Command] represented by this widget.
func get_command() -> Command:
	if _command_wref != null:
		return _command_wref.get_ref() as Command
	return null


## Returns a reference to [EditorCmdEventDock] containing this widget.
func get_dock() -> EditorCmdEventDock:
	if _editor_dock != null:
		return _editor_dock.get_ref() as EditorCmdEventDock
	return null


## Returns a refernce to [EditorCmdWidgetContainer] containing this widget.
func get_widget_container() -> EditorCmdWidgetContainer:
	if _container != null:
		return _container.get_ref() as EditorCmdWidgetContainer
	return null


## Sets selection state of this widget.
func set_selected(p_selected: bool) -> void:
	self.selected = p_selected
	_set_widget_color(_color)


#region SIGNALS
## Disconnects all possible connections this widget may have.
func disconnect_signals():
	_was_moved = true
	if _top_panel.clicked_on.is_connected(_on_selected):
		_top_panel.clicked_on.disconnect(_on_selected)
	if _top_panel.popup_requested.is_connected(_on_context_menu_popup_requested):
		_top_panel.popup_requested.disconnect(_on_context_menu_popup_requested)
	for p in _content_container.get_children():
		var property := p as EditorCmdCommandProperty
		if property != null && \
				property.property_changed.is_connected(_on_property_changed):
			property.property_changed.disconnect(_on_property_changed)


## Reconnects all signals after moving this widget to another [Container].
func reconnect(p_container: Container) -> void:
	if !_was_moved:
		return
	
	_container = weakref(p_container)
	_top_panel.clicked_on.connect(_on_selected)
	_top_panel.popup_requested.connect(_on_context_menu_popup_requested)
	for p in _content_container.get_children():
		var property := p as EditorCmdCommandProperty
		if property != null:
			property.property_changed.connect(_on_property_changed)
#endregion


#region CALLBACKS
func _on_selected() -> void:
	get_dock().grab_focus()
	get_dock().on_widget_selected(self)


func _on_property_changed(p_property_name: String, 
		p_property_value: Variant) -> void:
	var command = get_command()
	if command != null:
		command.set(p_property_name.to_snake_case(), p_property_value)
#endregion


#region PRIVATE_GETTERS
func _get_command_name(p_command: Command) -> String:
	if p_command.resource_name != "":
		return p_command.resource_name.to_pascal_case()
	
	var script := p_command.get_script() as Script
	if script != null:
		var raw_command_name = script.resource_path.get_file().get_basename()
		return raw_command_name.to_pascal_case()
	
	return "Command"


func _get_command_icon(p_command_name: String) -> Texture2D:
	var icon_path: String = Cmd.Config.command_icons_dir \
			+ p_command_name.to_snake_case() + ".svg"
	if ResourceLoader.exists(icon_path):
		return load(icon_path)
	return load(Cmd.Config.default_command_icon)
#endregion


#region PRIVATE_SETTERS
func _set_widget_name(p_name: String) -> void:
	_widget_name.set_text(p_name)


func _set_widget_icon(p_icon: Texture2D) -> void:
	_widget_icon.set_texture(p_icon)


func _set_widget_color(p_color: Color) -> void:
	_color = p_color
	var new_color = _color if !selected else _color.lightened(0.3)
	
	# Change widget titlebar color
	var _stylebox_fg := StyleBoxFlat.new()
	_stylebox_fg.bg_color = new_color
	_stylebox_fg.border_width_top = 1
	_stylebox_fg.border_color = p_color.darkened(0.1)
	_top_panel.add_theme_stylebox_override(&"panel", _stylebox_fg)
	
	# Change widget background color
	var _stylebox_bg := StyleBoxFlat.new()
	_stylebox_bg.bg_color = new_color.darkened(0.1)
	_stylebox_fg.border_width_bottom = 1
	_stylebox_fg.border_color = new_color.darkened(0.3)
	_content_panel.add_theme_stylebox_override(&"panel", _stylebox_bg)
#endregion


#region CONTEXT_MENU
func _setup_context_menu() -> void:
	add_child(_context_menu)
	_context_menu.add_item("Cut", EContextMenuOptions.CUT)
	_context_menu.add_item("Copy", EContextMenuOptions.COPY)
	_context_menu.add_item("Paste Above", EContextMenuOptions.PASTE_ABOVE)
	_context_menu.add_item("Paste Below", EContextMenuOptions.PASTE_BELOW)
	_context_menu.add_item("Delete", EContextMenuOptions.DELETE)
	_context_menu.id_pressed.connect(_on_context_menu_selected)


func _on_context_menu_popup_requested() -> void:
	_context_menu.set_position(get_global_mouse_position())
	_context_menu.popup()


func _on_context_menu_selected(p_id: int) -> void:
	match p_id:
		EContextMenuOptions.CUT:
			cut_requested.emit()
		EContextMenuOptions.COPY:
			copy_requested.emit()
		EContextMenuOptions.PASTE_ABOVE:
			paste_requested.emit(false)
		EContextMenuOptions.PASTE_BELOW:
			paste_requested.emit(true)
		EContextMenuOptions.DELETE:
			delete_requested.emit(self, get_widget_container())
		_:
			return
#endregion
