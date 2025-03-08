class_name LoopCommand extends Command

@export var condition: ConditionGroup
@export var commands: Array[Command]


@warning_ignore("untyped_declaration")
func execute(_event: GameEvent) -> void:
	if condition == null:
		push_warning("No conditions were set, nothing to evaluate!")
		finished.emit()
		return
	while condition.evaluate(_event):
		for cmd: Command in commands:
			if cmd is BreakLoopCommand:
				finished.emit()
				return # Break outer loop
			
			if cmd is SkipLoopCommand:
				break # Continue outer loop
			
			cmd.execute.call_deferred(_event)
			await cmd.finished
	
	finished.emit()
