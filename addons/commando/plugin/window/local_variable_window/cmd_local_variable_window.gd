## Local Event Variable [Window].
## Allows the user to add a new default Local Event Variable 
## to the currently edited [GameEvent].
@tool
class_name EditorCmdLocalVariableWindow extends Window

## Emitted when user clicks on "OK" button.
signal changes_commited(lev_name: String, lev_value: Variant)

var _property: Control = null
var _property_value: Variant = null

@onready var _property_container := %PropertyContainer as HBoxContainer
@onready var _change_type_button := %ChangeTypeButton as OptionButton
@onready var _name_edit := %NameEdit as LineEdit
@onready var _ok_button := %OkButton as Button
@onready var _cancel_button := %CancelButton as Button


func _ready() -> void:
	_change_type_button.clear()
	var base_control := EditorInterface.get_base_control()
	for type_enum: Variant.Type \
			in EditorCmdLocalEventVariableProperty.SUPPORTED_TYPES:
		var type_name := type_string(type_enum)
		var icon_name := type_name
		var icon = base_control.get_theme_icon(icon_name, "EditorIcons")
		if icon == null:
			icon = base_control.get_theme_icon("Variant", "EditorIcons")
		
		_change_type_button.add_icon_item(icon, type_name, type_enum)
	
	_ok_button.pressed.connect(finalize)
	_cancel_button.pressed.connect(
		func() -> void: 
			close_requested.emit()
	)
	
	_change_type_button.item_selected.connect(_on_type_changed)
	_change_type_button.select(0)
	_on_type_changed(0)


func finalize() -> void:
	if is_instance_valid(_property):
		if _property_value == null:
			# If the user never touched the editor, 
			# use whatever value the current property control holds.
			_property.get_property_value()
		if _property.property_changed.is_connected(_on_property_value_changed):
			_property.property_changed.disconnect(_on_property_value_changed)
		_property.queue_free()
		_property = null
	
	changes_commited.emit(
		_name_edit.get_text(),
		_property_value
	)
	close_requested.emit()


func _on_type_changed(index: int) -> void:
	if is_instance_valid(_property):
		if _property.property_changed.is_connected(_on_property_value_changed):
			_property.property_changed.disconnect(_on_property_value_changed)
		_property.queue_free()
		_property = null
	
	var _type = _change_type_button.get_item_id(index)
	var _hint = PropertyHint.PROPERTY_HINT_NONE #PROPERTY_HINT_RESOURCE_TYPE \
			#if _type_id == TYPE_OBJECT else PropertyHint.PROPERTY_HINT_NONE
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
		_property_value = _get_default_value(_type)
		_property.property_changed.connect(_on_property_value_changed)


func _get_default_value(p_type: Variant.Type) -> Variant:
	match p_type:
		TYPE_BOOL: 
			return false
		TYPE_INT: 
			return 0
		TYPE_FLOAT: 
			return 0.0
		TYPE_STRING: 
			return ""
		TYPE_STRING_NAME: 
			return &""
		TYPE_COLOR: 
			return Color.BLACK
		TYPE_NODE_PATH: 
			return ^""
		_: 
			return null


func _on_property_value_changed(_name: String, value: Variant) -> void:
	_property_value = value
