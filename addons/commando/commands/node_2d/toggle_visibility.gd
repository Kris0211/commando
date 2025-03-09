class_name ToggleVisibilityCommand extends Command

@export_node_path("CanvasItem") var node: NodePath
@export var visible: bool = true

func execute(_event: GameEvent) -> void:
	var _node := _event.get_node(node) as CanvasItem
	if _node != null:
		_node.visible = visible
	
	finished.emit()
