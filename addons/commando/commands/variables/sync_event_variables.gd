## Synchronizes Local Event Variables with another event.
class_name SyncEventVariablesCommand extends Command

enum ESyncDirection
{
	## Copies all variables from other event to this event.
	FROM_OTHER,
	## Copies all variables from this event to other event.
	TO_OTHER,
	## Merges variables from both events. This event has priority.
	MERGE_THIS,
	 ## Merges variables from both events. Other event has priority.
	MERGE_OTHER,
}

## Reference to [GameEvent] to sync Local Event Variable to.
@export_node_path("GameEvent") var other_event: NodePath
## Determines synchronization direction method
@export var sync_method: ESyncDirection = ESyncDirection.MERGE_THIS
## If set to [code]true[/code], uses [Dictionary.merge] 
## with [param overwrite] set to true
@export var force_overwrite: bool = false


func execute(_event: GameEvent) -> void:
	var other := _event.get_node_or_null(other_event) as GameEvent
	if other == null:
		push_error("Other GameEvent not set (or invalid NodePath).")
		finished.emit()
		return
	
	var _this_lec := _event.local_event_variables
	var _other_lec := other.local_event_variables
	match sync_method:
		ESyncDirection.FROM_OTHER:
			_this_lec.merge(_other_lec, force_overwrite)
		ESyncDirection.TO_OTHER:
			_other_lec.merge(_this_lec, force_overwrite)
		ESyncDirection.MERGE_THIS:
			var _merged := _this_lec.merged(_other_lec, force_overwrite)
			_event.local_event_variables = _merged
			other.local_event_variables = _merged
		ESyncDirection.MERGE_OTHER:
			var _merged := _other_lec.merged(_this_lec, force_overwrite)
			_event.local_event_variables = _merged
			other.local_event_variables = _merged
	
	finished.emit()
