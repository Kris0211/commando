class_name ToggleVisibility3DCommand extends Command

@export_node_path("Node3D") var node: NodePath
@export var visible: bool = true

func execute(_event: GameEvent) -> void:
	var _node := _event.get_node(node) as Node3D
	if _node != null:
		_node.visible = visible
	
	finished.emit()
