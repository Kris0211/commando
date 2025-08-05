## An abstract representation of a [Command] property editor.
@tool
class_name EditorCmdCommandProperty extends BoxContainer

## Emitted after changing property value.
signal property_changed(property_name: String, new_value: Variant)

## Reference to property editor control. 
## Varies by property type.
var property_editor: Control = null
## Reference to widget that contains this property.
var parent_widget: Control = null

@onready var _label: Label = get_child(0) # Assumes label is the first child.


## Get displayed property name
func get_property_name() -> String:
	return _label.get_text()


## Sets property display name.
func set_property_name(p_name: String) -> void:
	if p_name.is_empty():
		_label.set_visible(false)
		return
	
	_label.set_visible(true)
	_label.set_text(p_name.capitalize())


## Sets property value. Value type varies by property.
@warning_ignore("untyped_declaration")
func set_property_value(p_value):
	# This is an abstract method that has to be overriden by derived subclasses.
	pass
