class_name InstantiateSceneCommand extends Command

@export var packed_scene: PackedScene
@export_node_path("Node") var parent_node: NodePath

func execute(_event: GameEvent) -> void:
	if packed_scene == null:
		push_warning("No scene to instantiate.")
		finished.emit()
		return
	
	var _node := _event.get_node(parent_node)
	if _node == null:
		_node = _event
	
	var instance := packed_scene.instantiate()
	_node.add_child(instance)
	finished.emit()
