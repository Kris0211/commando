extends Node

@warning_ignore("unused_signal")
signal game_over # Use signal over call to notify GameEvents!

@export var mob_scene: PackedScene
#var score # Moved to Global.score

# Changed to GameOverEvent
#func game_over():
	#$ScoreTimer.stop()
	#$MobTimer.stop()
	#$HUD.show_game_over()
	#$Music.stop()
	#$DeathSound.play() # Moved to player scene


# Changed to NewGameEvent
#func new_game():
	#get_tree().call_group(&"mobs", &"queue_free")
	#score = 0
	#$Player.start($StartPosition.position)
	#$StartTimer.start()
	#$HUD.update_score(score)
	#$HUD.show_message("Get Ready")
	#$Music.play()


# Currently cannot be represented as GameEvent due to modifying new instance.
func _on_MobTimer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
	mob_spawn_location.progress = randi()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


# Currently cannot be represented as GameEven due to args in method call.
func _on_ScoreTimer_timeout():
	Global.score += 1
	$HUD.update_score(Global.score)


# Can be represented as GameEvent but is simple enough to leave it here.
func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
