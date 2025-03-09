class_name TweenRotation3DCommand extends Command

@export_node_path("Node3D") var node: NodePath
@export var pitch: float = 0.0
@export var yaw: float = 0.0
@export var roll: float = 0.0
@export var duration: float = 2.0
@export var transition: Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export var ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var wait_for_finished: bool = false

func execute(_event: GameEvent) -> void:
	var _target := _event.get_node(node) as Node3D
	if _target != null:
		
		var euler_angles := Vector3(
			deg_to_rad(pitch),
			deg_to_rad(yaw),
			deg_to_rad(roll)
		)
		var quaternion := Quaternion.from_euler(euler_angles)
		
		var _tween := _target.create_tween()
		_tween.tween_property(
			_target,
			^"rotation",
			quaternion.get_euler(),
			duration
		).set_trans(transition).set_ease(ease)
		if wait_for_finished:
			await _tween.finished
		
	finished.emit()
