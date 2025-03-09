class_name ReloadSceneCommand extends Command

@export var new_scene: PackedScene

func execute(_event: GameEvent) -> void:
	_event.process_commands = false
	_event.get_tree().reload_current_scene()
	finished.emit()
