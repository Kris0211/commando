class_name PlayAnimationCommand extends Command

@export_node_path("AnimationPlayer") var animation_player: NodePath
@export var animation_name: String = ""
@export var play_backwards: bool = false

func execute(_event: GameEvent) -> void:
	var _player := _event.get_node(animation_player) as AnimationPlayer
	if _player == null:
		push_warning("Failed to fecth AnimationPlayer node.")
		finished.emit()
		return
	
	if !play_backwards:
		_player.play(animation_name)
	else:
		_player.play_backwards(animation_name)
	
	finished.emit()
