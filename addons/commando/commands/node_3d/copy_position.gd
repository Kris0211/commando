class_name CopyPosition3DCommand extends Command

@export_node_path("Node3D") var from_node: NodePath
@export_node_path("Node3D") var to_node: NodePath

func execute(_event: GameEvent) -> void:
	var _from := _event.get_node(from_node) as Node3D
	if _from == null:
		push_warning("Unable to fetch node using path: %s" % from_node)
	
	var _to := _event.get_node(to_node) as Node3D
	if _to == null:
		push_warning("Unable to fetch node using path: %s" % to_node)
	
	if _from != null && _to != null:
		_to.position = _from.position
	
	finished.emit()
