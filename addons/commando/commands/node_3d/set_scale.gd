class_name SetScale3DCommand extends Command

@export_node_path("Node3D") var node: NodePath
@export var scale_x: float = 0.0
@export var scale_y: float = 0.0
@export var scale_z: float = 0.0

func execute(_event: GameEvent) -> void:
	var _target := _event.get_node(node) as Node3D
	if _target != null:
		var new_scale := Vector3(scale_x, scale_y, scale_z)
		_target.set_scale(new_scale)
	
	finished.emit()
