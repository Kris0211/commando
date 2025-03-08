## A custom [Command] that executes user-defined script.
class_name CustomCommand extends Command

## A [Script] for custom command logic. 
## Must extend [Command].
@export var custom_script: Script = null


## Triggers a custom [Command] logic.
@warning_ignore("untyped_declaration")
func execute(_event: GameEvent) -> Variant:
	if custom_script == null:
		printerr("No custom Command script set.")
		return
	
	var custom_command := custom_script.new() as Command
	if custom_command == null || !custom_command.has_method("execute"):
		printerr("Custom Command script is missing an 'execute()' method.")
		return
	
	return custom_command.call("execute", _event)


func _get_property_list() -> Array[Dictionary]:
	if custom_script == null:
		return []
	
	return custom_script.get_property_list()
