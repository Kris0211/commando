class_name ChangeCurrentSceneCommand extends Command

@export var new_scene: PackedScene

func execute(_event: GameEvent) -> void:
	_event.process_commands = false
	_event.get_tree().change_scene_to_packed(new_scene)
	finished.emit()
