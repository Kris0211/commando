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
	"event_commands",
	"process_commands",
	"_already_triggered",
	"trigger_conditions",
	"_local_event_variables",
	"process_mode",
	"process_priority",
	"process_physics_priority",
	"process_thread_group",
	"physics_interpolation_mode",
	"auto_translate_mode",
	"editor_description",
	"metadata/_custom_type_script",
]

## These properties are considered to be built-in plugin provided properties.
const EVENT_PROPERTIES := [
	"trigger_mode",
	"one_shot",
	"source_node",
	"signal_name",
	"trigger_delay",
]

# All the other properties are considered to be user defined 
# (i.e. derived classes) and will be added at the bottom as "User Properties"

const _SIGNAL_SELECTOR_SCENE := \
		preload("res://addons/commando/plugin/event_dock/signal_selector/cmd_signal_selector.tscn")

const _LEV_PROPERTY_SCENE := \
		preload("res://addons/commando/plugin/property/lev_property/cmd_lev_property.tscn")

var _ep_visible: bool = true
var _conds_visible: bool = true
var _lev_visible: bool = true
var _cup_visible: bool = true

# true if an event has user-defined properties (extends GameEvent)
var _has_cups: bool = false

var _window: Window = null

@onready var _cup_container := %CupContainer as VBoxContainer

@onready var _event_properties := %EventProperties as VBoxContainer
@onready var _conds_edit_button := %OpenCondsEditorButton as Button
@onready var _no_lev_label := %NoLevLabel as Label
@onready var _lev_content := %LevContent as PanelContainer
@onready var _lev_container := %LocalEventVariablesContainer as VBoxContainer
@onready var _cup_properties := %CupProperties as VBoxContainer

@onready var _toggle_ep_button:= %ToggleEPButton as Button
@onready var _toggle_conds_button := %ToggleCondsButton as Button
@onready var _toggle_lev_button := %ToggleLevButton as Button
@onready var _toggle_cup_button := %ToggleCupButton as Button


## Initializes event properties
func setup(p_event: GameEvent) -> void:
	if p_event != EditorCmdEventDock.event_node:
		printerr("Event mismatch detected. Please re-select event node.")
	
	# Clear previous properties
	for c in _event_properties.get_children():
		c.queue_free()
	
	for c in _lev_container.get_children():
		c.queue_free()
	
	_setup_properties(p_event)
	_setup_levs(p_event)
	
	_update_property_visibility()
	_cup_container.set_visible(_has_cups)


## Adds a property to event dock.
func add_property(p_property: Dictionary, p_value: Variant, 
		p_container: Control) -> void:
	var property := CmdPropertyFactory.create_property(p_property)
	if property == null:
		printerr("Failed to create property for %s!" % p_property)
		return
	
	_event_properties.add_child(property)
	property.parent_widget = self
	
	property.set_property_value(p_value)
	property.property_changed.connect(_on_property_changed)


## Adds a Local Event Variable to the event.
func add_local_event_variable(p_name: String, p_value: Variant) -> void:
	var _lev_property := _LEV_PROPERTY_SCENE.instantiate()
	_lev_container.add_child(_lev_property)
	_lev_property.setup(p_name, p_value)
	_lev_property.lev_edited.connect(_on_lev_edited)
	_lev_property.delete_requested.connect(remove_local_event_variable)


## Removes a Local Event Variable from this event.
func remove_local_event_variable(
			p_lev: EditorCmdLocalEventVariableProperty) -> void:
	EditorCmdEventDock.event_node._local_event_variables.erase(
			p_lev.get_property_name())
	p_lev.queue_free()
	_update_property_visibility()


## Static utility function that checks if property is exported
## and not excluded from use.
static func is_property_exported(p_property: Dictionary) -> bool:
	var property_name = p_property.get("name")
	if p_property.get("usage") & PROPERTY_USAGE_EDITOR == 0:
		return false
	
	return !(property_name in EXCLUDED_PROPERTIES)


func _setup_properties(p_event: GameEvent) -> void:
	# Create properties
	for cproperty: Dictionary in p_event.get_property_list():
		var cproperty_name: String = cproperty.get("name")
		if !is_property_exported(cproperty):
			continue
		
		if cproperty_name in EVENT_PROPERTIES:
			if cproperty.get("name") == "signal_name":
				var source_node := p_event.get_node_or_null(p_event.source_node)
				if source_node:
					_add_signal_selector(
						source_node,
						p_event.signal_name
					)
				continue
			
			add_property(
				cproperty, 
				p_event.get(cproperty.get("name")), 
				_event_properties
			)
		
		else: # User-defined property
			_has_cups = true
			add_property(
				cproperty, 
				p_event.get(cproperty.get("name")), 
				_cup_properties
			)


func _setup_levs(p_event: GameEvent) -> void:
	var levs := p_event._local_event_variables
	for lev_name: String in levs.keys():
		add_local_event_variable(lev_name, levs.get(lev_name))


func _on_lev_edited(p_name: String, p_value: Variant, 
		p_old_name: String) -> void:
	if p_name != p_old_name:
		EditorCmdEventDock.event_node._local_event_variables.erase(p_old_name)
	
	EditorCmdEventDock.event_node._local_event_variables[p_name] = p_value


func _add_signal_selector(source_node: Node, signal_name: StringName) -> void:
	var _signal_selector := _SIGNAL_SELECTOR_SCENE.instantiate()
	_event_properties.add_child(_signal_selector)
	_signal_selector.setup(source_node, signal_name)
	_signal_selector.selection_changed.connect(_on_property_changed)


func _update_property_visibility() -> void:
	for c in _event_properties.get_children():
		if c is CmdSignalSelector:
			# Use set_deferred() to wait for underlying event to update
			c.set_deferred(&"visible", \
						EditorCmdEventDock.event_node.trigger_mode == \
						GameEvent.EEventTrigger.ON_SIGNAL
				)
		
		var property := c as EditorCmdCommandProperty
		if property == null:
			continue
		
		match property.get_property_name().to_snake_case():
			"source_node":
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
	
	await get_tree().process_frame
	_no_lev_label.set_visible(_lev_container.get_child_count() == 0)


func _on_property_changed(p_property_name: String, 
		p_property_value: Variant) -> void:
	EditorCmdEventDock.event_node.set(
		p_property_name.to_snake_case(), p_property_value)
	if p_property_name.to_snake_case() == "trigger_mode":
		_update_property_visibility()


func _on_conditions_changed(p_conditions: ConditionGroup) -> void:
	EditorCmdEventDock.event_node.trigger_conditions = \
			p_conditions.duplicate(true)


func _on_open_conds_editor_button() -> void:
	if _window:
		return
	
	_window = EditorCmdEventDock.COND_WINDOW.instantiate() \
			as EditorCmdConditionGroupWindow
	
	if _window != null:
		add_child(_window)
		_window.changes_commited.connect(_on_conditions_changed)
		_window.close_requested.connect(_destroy_window)
		_window.setup(null)
		_window.popup_centered()


func _on_add_lev_button_pressed() -> void:
	CmdUtils.show_popup("Not implemented yet.", "Coming soon!")


func _on_toggle_ep_button_pressed() -> void:
	_ep_visible =! _ep_visible
	_toggle_ep_button.text = "v" if _ep_visible else ">"
	_event_properties.visible = _ep_visible


func _on_toggle_conds_button_pressed() -> void:
	_conds_visible =! _conds_visible
	_toggle_conds_button.text = "v" if _conds_visible else ">"
	_conds_edit_button.visible = _conds_visible


func _on_toggle_lev_button_pressed() -> void:
	_lev_visible =! _lev_visible
	_toggle_lev_button.text = "v" if _lev_visible else ">"
	_lev_content.visible = _lev_visible


func _on_toggle_cup_button_pressed() -> void:
	_cup_visible =! _cup_visible
	_toggle_cup_button.text = "v" if _cup_visible else ">"
	_cup_properties.visible = _cup_visible


func _destroy_window() -> void:
	if !is_instance_valid(_window):
		return
	
	if _window.close_requested.is_connected(_destroy_window):
		_window.close_requested.disconnect(_destroy_window)
	if _window.changes_commited.is_connected(_on_conditions_changed):
		_window.changes_commited.disconnect(_on_conditions_changed)
	
	_window.free.call_deferred()
	_window = null
