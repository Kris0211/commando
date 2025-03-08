class_name BreakLoopCommand extends Command

@warning_ignore("untyped_declaration")
func execute(_event: GameEvent) -> void:
	finished.emit()
