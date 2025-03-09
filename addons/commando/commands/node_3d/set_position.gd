class_name SetPosition3DCommand extends Command

# Vector2 is not supported yet.
@export_node_path("Node3D") var node: NodePath
@export var position_x: float = 0.0
@export var position_y: float = 0.0
@export var position_z: float = 0.0

func execute(_event: GameEvent) -> void:
	var _target := _event.get_node(node) as Node3D
	if _target != null:
		var new_position := Vector3(position_x, position_y, position_z)
		_target.set_position(new_position)
	
	finished.emit()
