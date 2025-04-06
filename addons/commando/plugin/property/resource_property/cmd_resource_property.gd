## Represents a command property editor for [Resource]s.
@tool
class_name EditorCmdResourceProperty extends EditorCmdCommandProperty

const _RES_MISMATCH := \
	"The selected resource does not match the expected type ({0})."

var _allowed_type: String

func _ready() -> void:
	var erp := EditorResourcePicker.new()
	erp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	erp.base_type = _allowed_type
	add_child(erp)
	
	property_editor = erp
	erp.resource_changed.connect(set_property_value)


## Sets property value. Value must inherit [Resource].
func set_property_value(p_resource: Resource) -> void:
	if p_resource == null:
		return
	
	if !_validate_resource(p_resource):
		CmdUtils.show_popup.call_deferred(_RES_MISMATCH.format([_allowed_type]))
		return
	
	if property_editor != null:
		(property_editor as EditorResourcePicker).edited_resource = p_resource
	
	property_changed.emit(_label.get_text(), p_resource)


## Sets allowed [Resource] types. 
## Only [Resource]s of that type as well as derived ones
## can be selected.
func set_allowed_types(p_types: String) -> void:
	_allowed_type = p_types
	if property_editor != null:
		(property_editor as EditorResourcePicker).base_type = _allowed_type


# Now that this uses EditorResourcePicker,
# validation should never fail,
# but better safe than sorry.
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
