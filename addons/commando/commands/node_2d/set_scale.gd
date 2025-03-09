class_name SetScale2DCommand extends Command

@export_node_path("Node2D") var node: NodePath
@export var scale_x: float = 0.0
@export var scale_y: float = 0.0

func execute(_event: GameEvent) -> void:
	var _target := _event.get_node(node) as Node2D
	if _target != null:
		var new_position := Vector2(scale_x, scale_y)
		_target.set_scale(new_position)
	
	finished.emit()
