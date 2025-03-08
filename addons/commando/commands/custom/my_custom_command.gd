extends Command

func execute(_event: GameEvent) -> void:
	# You can put any custom logic here.
	# Keep in mind exported properties will not appear in GameEvent widgets.
	print("This is a custom command!")
	finished.emit() # Don't forget to emit "finished" when execution ends.
