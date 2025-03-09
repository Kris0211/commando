## Suspends event execution for a given amount of time.
class_name WaitCommand extends Command

## Delay in seconds before resuming event execution.
@export var delay: int = 1

func execute(_event: GameEvent) -> void:
	await _event.get_tree().create_timer(max(0, delay))
	finished.emit()
