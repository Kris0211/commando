extends CanvasLayer

@warning_ignore("unused_signal")
signal start_game

# Default parameter added to satisfy "Invoke Method" command requirements
func show_message(text = "Game Over"):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()


# Changed to GameOverEvent
#func show_game_over():
	#show_message()
	#await $MessageTimer.timeout
	#$MessageLabel.text = "Dodge the\nCreeps"
	#$MessageLabel.show()
	#await get_tree().create_timer(1).timeout
	#$StartButton.show()


# Currently cannot be represented as GameEven due to args in method call.
func update_score(score):
	$ScoreLabel.text = str(score)


# Changed to ButtonPressedEvent
#func _on_StartButton_pressed():
	#$StartButton.hide()
	#start_game.emit()


# Can be represented as GameEvent but is simple enough to leave it here.
func _on_MessageTimer_timeout():
	$MessageLabel.hide()
