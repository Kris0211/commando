@tool
## A dock area for event properties.
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
const _SIGNAL_SELECTOR_SCENE := \
		preload("res://addons/commando/plugin/event_dock/signal_selector/cmd_signal_selector.tscn")

@onready var _event_properties := %EventProperties as VBoxContainer


## Initializes event properties
func setup(p_event: GameEvent) -> void:
	# Clear previous properties
	for c in _event_properties.get_children():
		c.queue_free()
	
	# Create properties
	for cproperty: Dictionary in p_event.get_property_list():
		if cproperty.get("name") == "signal_name":
			_add_signal_selector(
				p_event.get_node(p_event.source_node),
				p_event.signal_name)
			continue
		
		if is_property_exported(cproperty):
			add_property(cproperty, p_event.get(cproperty.get("name")))
	
	_update_property_visibility()


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
## and not excluded from use.
static func is_property_exported(p_property: Dictionary) -> bool:
	var property_name = p_property.get("name")
	if p_property.get("usage") & PROPERTY_USAGE_EDITOR == 0:
		return false
	
	return !(property_name in EXCLUDED_PROPERTIES)


func _add_signal_selector(source_node: Node, signal_name: StringName) -> void:
	var _signal_selector := _SIGNAL_SELECTOR_SCENE.instantiate()
	_event_properties.add_child(_signal_selector)
	_signal_selector.setup(source_node.get_signal_list(), signal_name)
	_signal_selector.selection_changed.connect(_on_property_changed)


func _update_property_visibility() -> void:
	for c in _event_properties.get_children():
		var property := c as EditorCmdCommandProperty
		if property == null:
			continue
		
		match property.get_property_name().to_snake_case():
			"signal_name", "source_node":
				# Use set_deferred() to wait for underlying event to update
				property.set_deferred(&"visible", \
						EditorCmdEventDock.event_node.trigger_mode == \
						GameEvent.EEventTrigger.ON_SIGNAL
				)
			"trigger_delay":
				property.set_deferred(&"visible", \
						EditorCmdEventDock.event_node.trigger_mode == \
						GameEvent.EEventTrigger.ON_TIMEOUT
				)
			_:
				property.set_deferred(&"visible", true)


func _on_property_changed(p_property_name: String, 
		p_property_value: Variant) -> void:
	EditorCmdEventDock.event_node.set(
		p_property_name.to_snake_case(), p_property_value)
	if p_property_name.to_snake_case() == "trigger_mode":
		_update_property_visibility()
