class_name ToggleCollision2DCommand extends Command

@export_node_path("CollisionShape2D") var collider: NodePath
@export var collision_enabled: bool = true

func execute(_event: GameEvent) -> void:
	var _col := _event.get_node(collider) as CollisionShape2D
	if _col != null:
		_col.set_deferred(&"disabled", !collision_enabled)
	
	finished.emit()
