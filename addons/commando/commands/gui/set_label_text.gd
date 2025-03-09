class_name SetLabelText extends Command

@export_node_path("Label") var label: NodePath
@export var text: String = ""

func execute(_event: GameEvent) -> void:
	var _label := _event.get_node(label) as Label
	if _label != null:
		_label.set_text(text)
	
	finished.emit()
