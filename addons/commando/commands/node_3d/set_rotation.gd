class_name SetRotation3DCommand extends Command

@export_node_path("Node3D") var node: NodePath
@export var pitch: float = 0.0
@export var yaw: float = 0.0
@export var roll: float = 0.0

func execute(_event: GameEvent) -> void:
	var _target := _event.get_node(node) as Node3D
	if _target != null:
		var euler_angles := Vector3(
			deg_to_rad(pitch),
			deg_to_rad(yaw),
			deg_to_rad(roll)
		)
		var quaternion := Quaternion.from_euler(euler_angles)
		_target.rotation = quaternion.get_euler()
	
	finished.emit()
