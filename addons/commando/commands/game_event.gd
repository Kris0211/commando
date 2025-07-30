## Executes [Command] logic during gameplay.
@icon("res://addons/commando/icons/command.svg")
class_name GameEvent extends Node

enum EEventTrigger {
	MANUAL, ## GameEvent needs to be triggered via code.
	ON_SIGNAL, ## Triggers when this event receives a signal from selected node.
	ON_READY, ## Triggers on [method Node._ready] callback.
	ON_TIMEOUT, ## Triggers repetadely after a set delay
	ON_PROCESS, ## Triggers every [method Node._process] tick.
	ON_PHYSICS_PROCESS, ## Triggers every [method Node._physics_process] tick.
}

const _NULL_SOURCE_ERR := "GameEvent '%s' is set to ON_SIGNAL, \
but no source node or signal name is defined!"
const _NO_SUCH_SIGNAL_WARN := "%s: Source node '%s' has no signal named '%s'."
const _ZERO_DELAY_WARN := "Trigger delay is set to 0 seconds."

## Condition for this event effects to trigger.
@export var trigger_mode := EEventTrigger.ON_SIGNAL

## When set to [code]true[/code], commands will be executed only once.
## Otherwise, this [GameEvent] will execute commands each time it triggers.
@export var one_shot: bool = false

@export_group("Signal Trigger")

## A reference to [Node] that will emit signal this [GameEvent] connects to.
@export_node_path("Node") var source_node: NodePath

## When invoking node emits a signal with this name, 
## this [GameEvent] will trigger.
@export var signal_name: StringName

@export_group("Timer")

## Timeout delay (in seconds)
@export var trigger_delay: float = 1.0

@export_group("")

## An [Array] containing associated [Command]s.
@export var event_commands: Array[Command] = []

## Should this [GameEvent] keep processing associated [Command]s?
var process_commands := true

# A [Dictionary] that contains user-defined event variables.
@export_storage var _local_event_variables: Dictionary = {}

# Used when one_shot is true to check if this event has been triggered before.
var _already_triggered: bool = false


func _ready() -> void:
	# Disable process callback for non-process events
	set_process(false)
	set_physics_process(false)
	add_to_group(&"events")
	match trigger_mode:
		EEventTrigger.MANUAL:
			pass # Do nothing; must be executed manually
		EEventTrigger.ON_READY:
			execute()
		EEventTrigger.ON_TIMEOUT:
			_start_timer()
		EEventTrigger.ON_PROCESS:
			set_process(true)
		EEventTrigger.ON_PHYSICS_PROCESS:
			set_physics_process(true)
		EEventTrigger.ON_SIGNAL:
			if source_node.is_empty() || signal_name.is_empty():
				push_error(_NULL_SOURCE_ERR % self.name)
				return
			
			var node := get_node(source_node)
			if node == null:
				return
				
			if !node.has_signal(signal_name):
				push_warning(_NO_SUCH_SIGNAL_WARN % \
						[self.name, node.name, signal_name])
				return
			
			# GameEvent does not care about signal arguments,
			# only about signal emission.
			node.connect(signal_name, _on_signal_trigger)


func _process(delta: float) -> void:
	if trigger_mode == EEventTrigger.ON_PROCESS:
		execute()


func _physics_process(delta: float) -> void:
	if trigger_mode == EEventTrigger.ON_PHYSICS_PROCESS:
		execute()


## Triggers this events's [Command]s.
func execute() -> void:
	if one_shot && _already_triggered:
		return
	
	_already_triggered = true
	process_commands = true
	for cmd: Command in event_commands:
		if !process_commands:
			break
		
		cmd.execute.call_deferred(self)
		await cmd.finished
	
	
	if one_shot:
		set_process(false)
		set_physics_process(false)


func _start_timer() -> void:
	if trigger_delay == 0.0:
		push_warning(_NO_SUCH_SIGNAL_WARN % signal_name)
	while true:
		await get_tree().create_timer(trigger_delay).timeout
		execute()


#region EVENT VARIABLES
## Sets a local event variable value.
## If a local event variable does not exist beforehand, adds it.
func set_local_event_variable(lev_name: String, lev_value: Variant) -> void:
	_local_event_variables[lev_name] = lev_value


## Returns a value of a local event variable.
## Returns [code]null[/code] if a local event variable does not exitst.
func get_local_event_variable(lev_name: String) -> Variant:
	if !_local_event_variables.has(lev_name):
		push_warning("Local event variable '%s' not found." % lev_name)
	
	return _local_event_variables.get(lev_name, null)
#endregion


#region PERSISTENCE
## Serializes this [GameEvent]. 
## Use this method to save the state of this Event for use in save system.
func serialize() -> Dictionary:
	return {
		"local_event_variables": _local_event_variables,
	}


## Deserializes this [GameEvent]. 
## Use this method to restore state from saved game.
func restore(data: Dictionary) -> void:
	if !data.is_empty():
		_local_event_variables = data.get("local_event_variables", {})
#endregion


func _on_signal_trigger(_arg1 = null, _arg2 = null, 
		_arg3 = null, _arg4 = null) -> void:
	# Discard signal arguments and execute commands.
	execute()
