##@experimental
## Suspends event execution until a signal is received.
class_name WaitForSignalCommand extends Command

@export_node_path("Node") var source_node: NodePath
@export var signal_name: String = ""

var _callback: Callable

func execute(_event: GameEvent) -> void:
	var source := _event.get_node(source_node) as Node
	if source == null:
		push_warning("Source node '%s' not found" % source_node)
		finished.emit()
		return
	
	if !source.has_signal(signal_name):
		push_warning("Node '%s' has no signal named '%s'" % \
		[source.name, signal_name])
		finished.emit()
		return
	
	
	_callback = func _on_signal_received(_arg1 = null, _arg2 = null, \
			_arg3 = null, _arg4 = null) -> void:
		source.disconnect(signal_name, _callback)
		finished.emit()
	
	var err := source.connect(signal_name, _callback)
	if err != OK:
		push_error("Failed to connect to signal '%s'!" % signal_name)
		finished.emit()
