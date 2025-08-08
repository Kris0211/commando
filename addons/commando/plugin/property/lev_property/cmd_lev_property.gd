## Represents a Local Event Variable in the dock editor.
@tool
class_name EditorCmdLocalEventVariableProperty extends HBoxContainer

## Types supported by Local Event Variables.
## The constants correspond to [b]Variant.Type[/b] enum values.
const SUPPORTED_TYPES := [
	TYPE_BOOL, 
	TYPE_INT, 
	TYPE_FLOAT, 
	TYPE_STRING,
	TYPE_STRING_NAME, ## @experimental
	TYPE_COLOR,
	TYPE_NODE_PATH, ## @experimental
	#TYPE_OBJECT ##@deprecated
]

## Emitted when users want to delete a Local Event Variable from edited event.
signal delete_requested(lev: EditorCmdLocalEventVariableProperty)
## Emitted when a Local Event Variable name or value changes.[br]
## NOTE: Currently renaming variables is not supported.
signal lev_edited(lev_name: String, lev_value: Variant, old_name: String)

@onready var _property_container := $PropertyContainer as HBoxContainer
@onready var _name_edit := %NameEdit as LineEdit
@onready var _change_type_button := %ChangeTypeButton as OptionButton
@onready var _delete_button := %DeleteButton as Button

var _property: Control = null

func _ready() -> void:
	_change_type_button.clear()
	var base_control := EditorInterface.get_base_control()
	for type_enum: Variant.Type in SUPPORTED_TYPES:
		var type_name := type_string(type_enum)
		var icon_name := type_name
		var icon = base_control.get_theme_icon(icon_name, "EditorIcons")
		if icon == null:
			icon = base_control.get_theme_icon("Variant", "EditorIcons")
		
		_change_type_button.add_icon_item(icon, type_name, type_enum)


## Initializes this Local Event Variable property editor.
func setup(p_name: String, p_value: Variant) -> void:
	_name_edit.set_text(p_name)
	
	var _type := typeof(p_value)
	if !SUPPORTED_TYPES.has(_type):
		_create_empty_property("<unsupported>")
		return
	
	for i: int in _change_type_button.item_count:
		if _change_type_button.get_item_text(i) == type_string(_type):
			_change_type_button.select(i)
			break
	
	var _hint = PROPERTY_HINT_RESOURCE_TYPE \
			if _type == TYPE_OBJECT else PropertyHint.PROPERTY_HINT_NONE
	_property = CmdPropertyFactory.create_property(
		{
			"name": String(),
			"type": _type,
			"hint": _hint,
		}
	)
	
	if _property != null:
		_property_container.add_child(_property)
		_property.property_editor.size_flags_horizontal = \
				Control.SIZE_EXPAND_FILL
		_property.set_property_name("")
		_property.set_property_value(p_value)
		_property.property_changed.connect(_on_property_changed)


## Returns the name of a property associated with this editor.
func get_property_name() -> String:
	return _name_edit.get_text()


func _create_empty_property(p_text: String) -> void:
	_property = LineEdit.new()
	_property.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_property_container.add_child(_property)
	var _line_edit := _property as LineEdit
	_line_edit.set_text(p_text)
	_line_edit.editable = false


func _on_property_changed(_property_name: String, new_value: Variant) -> void:
	lev_edited.emit(_name_edit.get_text(), new_value, _name_edit.get_text())


func _on_change_type_button_item_selected(index: int) -> void:
	var new_type: int = _change_type_button.get_item_id(index)
	
	if !SUPPORTED_TYPES.has(new_type):
		return

	if _property:
		_property_container.remove_child(_property)
		_property.queue_free()
		_property = null
	
	if new_type == TYPE_NIL:
		_create_empty_property("<null>")
		return
	
	var _hint = PROPERTY_HINT_RESOURCE_TYPE \
			if new_type == TYPE_OBJECT else PropertyHint.PROPERTY_HINT_NONE
	_property = CmdPropertyFactory.create_property(
		{
			"name": String(),
			"type": new_type,
			"hint": _hint,
		}
	)
	
	if _property:
		_property_container.add_child(_property)
		_property.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_property.property_editor.size_flags_horizontal = \
				Control.SIZE_EXPAND_FILL
		_property.set_property_name("")
		_property.property_changed.connect(_on_property_changed)


func _on_delete_button_pressed() -> void:
	delete_requested.emit(self)
