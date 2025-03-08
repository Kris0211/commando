## Executes [Command] logic during gameplay.
class_name GameEvent extends Node

## An [Array] containing associated [Command]s.
@export var event_commands: Array[Command]

## Should this [GameEvent] keep processing associated [Command]s?
var process_commands := false

# A [Dictionary] that contains user-defined event variables.
@export_storage var _local_event_variables := {}


func _ready() -> void:
	add_to_group(&"events")


## Triggers this events's [Command]s.
func execute() -> void:
	for cmd: Command in event_commands:
		if !process_commands:
			break
		
		cmd.execute.call_deferred(self)
		await cmd.finished


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

func serialize() -> Dictionary:
	return {
		"local_event_variables": _local_event_variables,
	}


func deserialize(data: Dictionary) -> void:
	if !data.is_empty():
		_local_event_variables = data.get("local_event_variables", {})

#endregion
