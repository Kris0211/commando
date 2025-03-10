class_name InvokeMethodCommand extends Command

@export_node_path("Node") var source_node: NodePath
@export var method_name: String = ""
# TODO: Add support for supplying arguments to method.

func execute(_event: GameEvent) -> void:
	var source := _event.get_node(source_node) as Node
	if source != null:
		if !source.has_method(method_name):
			push_warning("%s: Node '%s' has no method named '%s'" % \
			[_event.name, source.name, method_name])
			finished.emit()
			return
		
		source.call(method_name)
	
	finished.emit()
