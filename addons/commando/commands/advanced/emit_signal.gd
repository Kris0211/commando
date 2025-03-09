class_name EmitSignalCommand extends Command

@export_node_path("Node") var source_node: NodePath
@export var signal_name: String = ""

func execute(_event: GameEvent) -> void:
	var source := _event.get_node(source_node) as Node
	if source != null:
		if !source.has_signal(signal_name):
			push_warning("Node '%s' has no signal named '%s'" % \
			[source.name, signal_name])
			finished.emit()
			return
		
		source.emit_signal(signal_name)
	
	finished.emit()
