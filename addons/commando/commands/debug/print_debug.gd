class_name PrintDebugCommand extends Command

## Debug message to display. Supports BBCode.
@export_multiline var debug_message: String

@warning_ignore("untyped_declaration")
func execute(_event):
	print_rich(debug_message)
	finished.emit()
