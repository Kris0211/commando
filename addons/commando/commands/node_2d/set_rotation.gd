class_name SetRotation2DCommand extends Command

@export_node_path("Node2D") var node: NodePath
@export var rotation: float = 0.0
@export var use_radians: bool = false

func execute(_event: GameEvent) -> void:
	var _target := _event.get_node(node) as Node2D
	if _target != null:
		if use_radians:
			_target.rotation = rotation
		else:
			_target.rotation_degrees = rotation
	
	finished.emit()
