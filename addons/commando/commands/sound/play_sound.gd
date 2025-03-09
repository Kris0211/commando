## Plays a one-shot sound. Does not require an existing [AudioStreamPlayer].
class_name PlaySoundCommand extends Command

@export var sound_file: AudioStream

func execute(_event: GameEvent) -> void:
	var _sound_player := AudioStreamPlayer.new()
	_sound_player.set_stream(sound_file)
	_sound_player.loop
	_event.add_child(_sound_player)
	_sound_player.finished.connect(
		func(): _sound_player.queue_free.call_deferred()
	)
	_sound_player.play()
	
	finished.emit()
