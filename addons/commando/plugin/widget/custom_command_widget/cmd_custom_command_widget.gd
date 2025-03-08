## A widget representing a user-defined [CustomCommand] in GUI dock editor.
@tool
class_name EditorCmdCustomCommandWidget extends EditorCmdCommandWidget

const _NOT_CMD_ERROR := "Selected script does not extend Command."
const _INSTANCE_FAIL_ERROR := \
	"Failed to create command instance. Is the script extending Command?"
const _CUSTOM_CMD_ERROR := \
	"Custom command extending CustomCommand detected. Extend Command instead."

## Holds a [Script] that will be parsed at runtime.
var command_script: Script = null

@onready var _script_button := %ScriptButton as Button
@onready var _edit_button := %EditButton as Button

func _ready() -> void:
	super()
	_script_button.pressed.connect(_on_script_button_pressed)
	_edit_button.pressed.connect(_on_edit_button_pressed)


## Initializes this widget.
func setup(p_command: Command, p_dock: Control, p_container: Container) -> void:
	super(p_command, p_dock, p_container)
	var _command_resource := (_command_wref.get_ref() as CustomCommand)
	if _command_resource != null:
		var _cscript = _command_resource.custom_script
		if _cscript != null:
			_set_script(_cscript.get_path())


func _set_script(p_path: String) -> void:
	_edit_button.hide()
	command_script = load(p_path) as Script
	if command_script == null || !_validate_script(command_script):
		printerr(_NOT_CMD_ERROR)
		return
	
	var command := command_script.new() as Command
	if command == null:
		printerr(_INSTANCE_FAIL_ERROR)
		return
	
	var _command_resource := (_command_wref.get_ref() as CustomCommand)
	if _command_resource != null:
		_command_resource.custom_script = command_script
	
	var script_name: String = command_script\
			.get_path()\
			.get_file()\
			.capitalize()
	_script_button.set_text("Change Script")
	_set_widget_name(script_name.get_slice(".", 0))
	_edit_button.show()


func _validate_script(p_script: Script) -> bool:
	# 'null' is considered valid to not raise errors before setting any script
	if p_script == null:
		return true
	
	var script: Script = p_script
	while script:
		var script_class: StringName = script.get_global_name()
		if script_class == "Command":
			return true
		elif script_class == "CustomCommand":
			printerr(_CUSTOM_CMD_ERROR)
			return false
		script = script.get_base_script()
	
	return false


func _change_script(p_script: Script) -> void:
	_set_script(p_script.get_path())
	_on_edit_button_pressed()
	_disconnect_dialog()


func _on_script_button_pressed() -> void:
	var create_dialog := get_dock().get_script_create_dialog()
	create_dialog.script_created.connect(_change_script)
	create_dialog.canceled.connect(_disconnect_dialog)
	create_dialog.set_title("Assign Script")
	create_dialog.config(
		"Command", 
		Cmd.Config.command_root_dir, 
		false
	)
	create_dialog.popup_centered()


func _on_edit_button_pressed() -> void:
	EditorInterface.set_main_screen_editor("Script")
	EditorInterface.edit_script(command_script)


func _disconnect_dialog() -> void:
	var create_dialog := get_dock().get_script_create_dialog()
	create_dialog.script_created.disconnect(_change_script)
	create_dialog.canceled.disconnect(_disconnect_dialog)
