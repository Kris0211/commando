## Represents a command property editor for [Resource]s.
@tool
class_name EditorCmdResourceProperty extends EditorCmdCommandProperty

const _RES_MISMATCH := \
	"The selected resource does not match the expected type ({0})."

var _allowed_type: String

func _ready() -> void:
	property_editor = $Button as Button
	(property_editor as Button).pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	var file_dialog := CmdUtils.show_file_dialog(
		"res://",
		_get_filters(_allowed_type)
	)
	file_dialog.file_selected.connect(_load_resource)


## Sets property value. Value must inherit [Resource].
func set_property_value(p_resource: Resource) -> void:
	if p_resource == null:
		return
	
	if !_validate_resource(p_resource):
		CmdUtils.show_popup.call_deferred(_RES_MISMATCH.format([_allowed_type]))
		return
	
	var _resource_filename = p_resource.get_path().get_file()\
			.get_slice(".", 0).to_pascal_case()
	(property_editor as Button).set_text(_resource_filename)
	(property_editor as Button).set_button_icon(_get_resource_icon(p_resource))
	
	property_changed.emit(_label.get_text(), p_resource)


## Sets allowed [Resource] types. 
## Only [Resource]s of that type as well as derived ones
## can be selected.
func set_allowed_types(p_types: String) -> void:
	_allowed_type = p_types


func _load_resource(p_path: String) -> void:
	var file := ResourceLoader.load(p_path, _allowed_type, \
			ResourceLoader.CacheMode.CACHE_MODE_IGNORE)
		
	if file == null:
		CmdUtils.show_popup.call_deferred(
			"Failed to load file: Unknown error (or resource does not exist)")
		return
	
	set_property_value(file)


func _validate_resource(p_resource: Resource) -> bool:
	# Empty resources are considered valid
	# as otherwise an error is raised on command creation.
	if p_resource == null:
		return true
	
	# Check built-in resources
	if p_resource.is_class(_allowed_type):
		return true
	
	# Check custom resources
	var script: Script = p_resource.get_script()
	while script:
		var script_class: StringName = script.get_global_name()
		if script_class == _allowed_type:
			return true
		script = script.get_base_script()
	
	return false


func _get_filters(p_type: String) -> PackedStringArray:
	var _filters := []
	var _extensions := ResourceLoader.get_recognized_extensions_for_type(p_type)
	for _ext in _extensions:
		_filters.append("*." + _ext)
	
	return _filters


func _clear_selection() -> void:
	(property_editor as Button).set_text("<empty>")
	(property_editor as Button).set_button_icon(null)


func _get_resource_icon(p_resource: Resource) -> Texture2D:
	# Fallback option until I figure out how to extract @icon annotation
	return EditorInterface.get_editor_theme().get_icon(
			"Object", "EditorIcons")
