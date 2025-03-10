class_name ToggleVisibilityControlCommand extends Command

@export_node_path("Control") var node: NodePath
@export var visible: bool = true

func execute(_event: GameEvent) -> void:
	var _node := _event.get_node(node) as Control
	if _node != null:
		_node.set_visible(visible)
	
	finished.emit()
