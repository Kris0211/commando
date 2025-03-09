# This is a custom command! It might not be the best use case,
# but it's here to show you it's possible to do so!
extends Command

func execute(_event: GameEvent) -> void:
	var parent_button := _event.get_parent() as Button
	if parent_button != null:
		parent_button.visible = false
	var hud := parent_button.get_parent() as CanvasLayer
	if hud != null:
		hud.start_game.emit()
