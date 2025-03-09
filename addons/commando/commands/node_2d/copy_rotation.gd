class_name CopyRotation2DCommand extends Command

@export_node_path("Node2D") var from_node: NodePath
@export_node_path("Node2D") var to_node: NodePath

func execute(_event: GameEvent) -> void:
	var _from := _event.get_node(from_node) as Node2D
	if _from == null:
		push_warning("Unable to fetch node using path: %s" % from_node)
	
	var _to := _event.get_node(to_node) as Node2D
	if _to == null:
		push_warning("Unable to fetch node using path: %s" % to_node)
	
	if _from != null && _to != null:
		_to.rotation = _from.rotation
	
	finished.emit()
