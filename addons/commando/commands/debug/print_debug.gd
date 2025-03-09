class_name PrintDebugCommand extends Command

## Debug message to display. Supports BBCode.
@export_multiline var debug_message: String

func execute(_event: GameEvent) -> void:
	print_rich(debug_message)
	finished.emit()
