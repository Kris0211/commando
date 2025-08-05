## Creates property editors for command widgets.
@tool
class_name CmdPropertyFactory

## Bool property editor scene.
static var bool_property: PackedScene \
	= preload("res://addons/commando/plugin/property/bool_property/cmd_bool_property.tscn")

## Enum property editor scene.
static var enum_property: PackedScene \
	= preload("res://addons/commando/plugin/property/enum_property/cmd_enum_property.tscn")

## NodePath property editor scene.
static var node_path_property: PackedScene \
	= preload("res://addons/commando/plugin/property/node_path_property/cmd_node_path_property.tscn")

## Number (int/float) property editor scene.
static var number_property: PackedScene \
	= preload("res://addons/commando/plugin/property/number_property/cmd_number_property.tscn")

## Resource property editor scene.
static var resource_property: PackedScene \
	= preload("res://addons/commando/plugin/property/resource_property/cmd_resource_property.tscn")

## Multiline string property editor scene.
static var multiline_property: PackedScene \
	= preload("res://addons/commando/plugin/property/string_multiline_property/cmd_string_multiline_property.tscn")

## String property editor scene.
static var string_property: PackedScene \
	= preload("res://addons/commando/plugin/property/string_property/cmd_string_property.tscn")

## Color property editor scene.
static var color_property: PackedScene \
	= preload("res://addons/commando/plugin/property/color_property/cmd_color_property.tscn")


## Creates a widget property based on [Dictionary] with property data.
static func create_property(p_property: Dictionary) -> EditorCmdCommandProperty:
	# {"name": "text", "type": TYPE_STRING, 
	# "hint": PROPERTY_HINT_NONE, "usage": PROPERTY_USAGE_DEFAULT}
	var property_name: String = p_property.get("name")
	var property_type: Variant.Type = p_property.get("type", 0)
	var property_hint: PropertyHint = p_property.get("hint", 0)
	var property_hint_string: String = p_property.get("hint_string", "")
	var property_instance: EditorCmdCommandProperty = null
	
	match property_type:
		# Boolean
		TYPE_BOOL:
			property_instance = bool_property.instantiate()
		
		# Enum
		TYPE_INT, TYPE_STRING when property_hint == PROPERTY_HINT_ENUM:
			property_instance = enum_property.instantiate()
			property_instance.set_enum_type(property_type)
			property_instance.set_options(property_hint_string)
		
		# Number (int or float)
		TYPE_INT, TYPE_FLOAT:
			property_instance = number_property.instantiate()
		
		# Multiline string
		TYPE_STRING when property_hint == PROPERTY_HINT_MULTILINE_TEXT:
			property_instance = multiline_property.instantiate()
		
		# Signle-line string
		TYPE_STRING, TYPE_STRING_NAME:
			property_instance = string_property.instantiate()
		
		# Resource reference
		TYPE_OBJECT when property_hint == PROPERTY_HINT_RESOURCE_TYPE:
			property_instance = resource_property.instantiate()
			property_instance.set_allowed_types(property_hint_string)
		
		# Node path
		TYPE_NODE_PATH:
			property_instance = node_path_property.instantiate()
			if property_hint == PROPERTY_HINT_NODE_PATH_VALID_TYPES:
				property_instance.set_allowed_types(
						property_hint_string.split(","))
		
		# Color
		TYPE_COLOR:
			property_instance = color_property.instantiate()
			property_instance.toggle_alpha(
					property_hint != PROPERTY_HINT_COLOR_NO_ALPHA)
	
	return property_instance
