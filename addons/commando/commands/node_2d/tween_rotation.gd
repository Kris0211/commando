class_name TweenRotation2DCommand extends Command

@export_node_path("Node2D") var node: NodePath
@export var rotation: float = 0.0
@export var use_radians: bool = false
@export var duration: float = 2.0
@export var transition: Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export var ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var wait_for_finished: bool = false

func execute(_event: GameEvent) -> void:
	var _target := _event.get_node(node) as Node2D
	if _target != null:
		var new_rotation: float
		if use_radians:
			new_rotation = rotation
		else:
			new_rotation = rotation
		
		var _tween := _target.create_tween()
		_tween.tween_property(
			_target,
			^"rotation",
			new_rotation,
			duration
		).set_trans(transition).set_ease(ease)
		if wait_for_finished:
			await _tween.finished
		
	finished.emit()
