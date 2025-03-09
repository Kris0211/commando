## Plays a music file using existing [AudioStreamPlayer] node.
class_name PlayMusicCommand extends Command

## [AudioStream] resource containing music.
@export var music_file: AudioStream
## [NodePath] to audio player node.
@export_node_path("AudioStreamPlayer") var audio_player: NodePath

func execute(_event: GameEvent) -> void:
	var _player_node := _event.get_node(audio_player) as AudioStreamPlayer
	if _player_node == null:
		push_warning("Failed to fetch audio player node.")
		return
	
	_player_node.stream = music_file
	_player_node.play()
	
	finished.emit()
