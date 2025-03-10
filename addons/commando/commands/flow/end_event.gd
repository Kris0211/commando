## Immediately terminates and hides [GameEvent] to which this is attached.
class_name EndEvent extends Command

func execute(_event: GameEvent) -> void:
	_event.process_commands = false
	_event.visible = false
	finished.emit()
