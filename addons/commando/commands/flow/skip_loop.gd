## Skips the current iteration of [LoopCommand].
class_name SkipLoopCommand extends Command

@warning_ignore("untyped_declaration")
func execute(_event: GameEvent) -> void:
	finished.emit()
