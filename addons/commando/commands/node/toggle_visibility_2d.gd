class_name ToggleVisibilityCommand extends Command

@export_node_path("Node2D") var node: NodePath
@export var visible: bool = true

func execute(_event: GameEvent) -> void:
	print(node)
	var _node2d := _event.get_node(node) as Node2D
	if _node2d != null:
		_node2d.visible = visible
	
	finished.emit()
