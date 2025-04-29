@tool
class_name EditorCmdEventProperties extends PanelContainer

## These properties will be excluded from command widgets & event properties.
const EXCLUDED_PROPERTIES := [
	"resource_local_to_scene", 
	"resource_path",
	"resource_name",
	"resource_scene_unique_id",
	"script",
	"custom_script",
	"condition",
	"effects_if_true",
	"effects_if_false",
	"commands",
	"event_commands",
	"process_mode",
	"process_priority",
	"process_physics_priority",
	"process_thread_group",
	"physics_interpolation_mode",
	"auto_translate_mode",
	"editor_description",
	"metadata/_custom_type_script",
]

@onready var _event_properties := %EventProperties as VBoxContainer


## Initializes event properties
func setup(p_event: GameEvent) -> void:
	# Clear previous properties
	for c in _event_properties.get_children():
		c.queue_free()
	
	# Create properties
	for cproperty: Dictionary in p_event.get_property_list():
		if is_property_exported(cproperty):
			add_property(cproperty, p_event.get(cproperty.get("name")))


## Adds a property to event dock.
func add_property(p_property: Dictionary, p_value: Variant) -> void:
	var property := CmdPropertyFactory.create_property(p_property)
	if property == null:
		printerr("Failed to create property for %s!" % p_property)
		return
	
	_event_properties.add_child(property)
	property.parent_widget = self
	
	var property_name = p_property.get("name")
	property.set_property_name(property_name)
	property.set_property_value(p_value)
	property.property_changed.connect(_on_property_changed)


## Static utility function that checks if property is exported
## and not excluded from use
static func is_property_exported(p_property: Dictionary) -> bool:
	var property_name = p_property.get("name")
	if p_property.get("usage") & PROPERTY_USAGE_EDITOR == 0:
		return false
	
	return !(property_name in EXCLUDED_PROPERTIES)


func _on_property_changed(p_property_name: String, 
		p_property_value: Variant) -> void:
	EditorCmdEventDock.event_node.set(
		p_property_name.to_snake_case(), p_property_value)
	if p_property_name.to_snake_case() == "trigger_mode":
		_update_property_visibility()


func _update_property_visibility() -> void:
	for c in _event_properties.get_children():
		var property := c as EditorCmdCommandProperty
		if property == null:
			print(c.name)
			continue
		
		match property.get_property_name().to_snake_case():
			"signal_name", "source_node":
				# Use set_deferred() to wait for underlying event to update
				property.set_deferred(&"visible", \
						EditorCmdEventDock.event_node.trigger_mode == \
						GameEvent.EEventTrigger.ON_SIGNAL
				)
			_:
				property.set_deferred(&"visible", true)
