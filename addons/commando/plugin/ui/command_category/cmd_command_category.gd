## Groups commands from one category inside creation dialog [Window].
@tool
class_name EditorCmdCommandCategory extends PanelContainer

@onready var _panel_bg := %BackgroundPanel as PanelContainer
@onready var _content := %ContentContainer as VBoxContainer
@onready var _category_name := %CategoryName as Label


## Changes category name (displayed as header) to a new one.
func set_category_name(p_name: String) -> void:
	_category_name.set_text(p_name)


## Changes category color.
func set_category_color(p_color: Color) -> void:
	var _color = Cmd.Config.colors.default \
			if !Cmd.Config.use_category_colors || p_color == Color.BLACK \
			else p_color
	
	var _stylebox_fg := StyleBoxFlat.new()
	_stylebox_fg.bg_color = _color
	_stylebox_fg.border_width_top = 2
	_stylebox_fg.border_width_bottom = 2
	_stylebox_fg.border_width_left = 2
	_stylebox_fg.border_width_right = 2
	_stylebox_fg.border_color = _color.darkened(0.15)
	add_theme_stylebox_override(&"panel", _stylebox_fg)
	
	var _stylebox_bg := StyleBoxFlat.new()
	_stylebox_bg.bg_color = _color.darkened(0.25)
	_panel_bg.add_theme_stylebox_override(&"panel", _stylebox_bg)


## Create a button that adds a corresponding command.
## Returns a reference to newly created button.
func add_command_button(p_command_name: String) -> Button:
	var button := Button.new()
	button.set_text(p_command_name)
	_content.add_child(button)
	return button
