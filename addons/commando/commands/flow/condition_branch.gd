class_name ConditionBranchCommand extends Command

@export_storage var condition: ConditionGroup
@export_storage var commands_if_true: Array[Command]
@export_storage var commands_if_false: Array[Command]


@warning_ignore("untyped_declaration")
func execute(_event: GameEvent):
	if condition == null:
		push_warning("No conditions were set, nothing to evaluate!")
		finished.emit()
		return
	
	if condition.evaluate(_event):
		if commands_if_true.is_empty():
			push_warning("Condition is true, but no commands were set to run.")
			finished.emit()
			return
		for cmd: Command in commands_if_true:
			if cmd != null:
				cmd.execute.call_deferred(_event)
				await cmd.finished
	elif !commands_if_false.is_empty():
			for cmd: Command in commands_if_false:
				if cmd != null:
					cmd.execute.call_deferred(_event)
					await cmd.finished
	
	finished.emit()
