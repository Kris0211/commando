class_name ToggleVisibility2DCommand extends Command

@export_node_path("Node2D") var node: NodePath
@export var visible: bool = true

func execute(_event: GameEvent) -> void:
	var _node := _event.get_node(node) as Node2D
	if _node != null:
		_node.set_visible(visible)
	
	finished.emit()
