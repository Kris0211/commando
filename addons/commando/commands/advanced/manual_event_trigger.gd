class_name ManualEventTriggerCommand extends Command

@export_node_path("GameEvent") var event: NodePath

func execute(_event: GameEvent) -> void:
	var other_event := _event.get_node(event) as GameEvent
	if other_event == null:
		push_warning("%s: Event not found. Path: %s" % \
			[_event.name, event])
		finished.emit()
		return
	
	if other_event == _event:
		push_warning("%s: An event cannot trigger itself" % _event.name)
		finished.emit()
		return
	
	other_event.execute()
	finished.emit()
