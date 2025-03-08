## Represents a command property editor for enums.
## Supports enums created with @export_enum, (both [int] and [String]),
## as well as named enums with or without explicitly defined values.
@tool
extends EditorCmdCommandProperty

## An [Array] for enum names.
var options := []
## An [Array] for enum values.
var values := []
## Determines whether this enum is represented by [String][br]
## ([annotation @GDScript.@export_enum] of type String)
var is_string_enum: bool

func _ready() -> void:
	property_editor = $OptionButton as OptionButton
	for i: int in options.size():
		(property_editor as OptionButton).add_item(options[i], i)
	
	(property_editor as OptionButton).item_selected.connect(_on_item_selected)


## Sets enum options inside [OptionButton], 
## as well as associating enum names with values.
func set_options(p_options: String) -> void:
	options.clear()
	values.clear()
	
	var enum_options: PackedStringArray = p_options.split(",")
	var i := 0
	for option: String in enum_options:
		if ":" in option:
			var option_name := option.get_slice(":", 0)
			var option_value := int(option.get_slice(":", 1))
			values.push_back(option_value)
			if Cmd.Config.display_enum_values:
				options.push_back(option)
			else:
				options.push_back(option_name)
		else:
			options.push_back(option)
			if is_string_enum:
				values.push_back(option)
			else:
				values.push_back(i)
		i += 1


## Sets enum type to determine whether this enum is a [String] enum.
func set_enum_type(p_type: Variant.Type) -> void:
	match p_type:
		TYPE_STRING:
			is_string_enum = true
		TYPE_INT:
			is_string_enum = false
		_:
			printerr("Unsupported enum type: %s" % p_type)


## Sets property value. Supported value types are [int] and [String].
func set_property_value(p_value: Variant) -> void:
	var idx: int = -1
	if p_value is String:
		idx = options.find(str(p_value))
	elif p_value is int:
		idx = values.find(int(p_value))
	else:
		printerr("Unsupported value type: %s" % type_string(typeof(p_value)))
		return
	
	if idx != -1:
		(property_editor as OptionButton).select(idx)


func _on_item_selected(p_index: int) -> void:
	property_changed.emit(_label.get_text(), values[p_index])
