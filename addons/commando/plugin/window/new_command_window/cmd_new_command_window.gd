## A [Window] displaying [Command]s that can be added to a [GameEvent].
@tool
class_name EditorNewCommandWindow extends Window

## Emitted when a command is successfully added to event.
signal command_added(command: Command)
## Emitted when requesting filesystem scan for command categories.
signal scan_requested

const CATEGORY_SCENE := \
	preload("res://addons/commando/plugin/ui/command_category/cmd_command_category.tscn")

@onready var _category_container := %CategoryContainer as GridContainer


func _enter_tree() -> void:
	scan_requested.emit()


func populate(p_category_map: Dictionary) -> void:
	if p_category_map == null:
		printerr("Failed to fetch categories! Try reloading the plugin.")
		return
	
	for cat: String in p_category_map.keys():
		var category := CATEGORY_SCENE.instantiate() as EditorCmdCommandCategory
		var category_name := cat.to_snake_case()
		_category_container.add_child(category)
		category.set_category_name(cat.capitalize())
		category.set_category_color(Cmd.Config.colors[category_name])
		var scripts_path := str(Cmd.Config.command_root_dir + category_name)
		var command_scripts: PackedStringArray = \
			DirAccess.get_files_at(scripts_path)
		
		for script: String in command_scripts:
			# Currently only supports GDScript.
			if !script.ends_with(".gd"):
				continue
			
			var command_name := script.get_basename().capitalize()
			var script_path: String = scripts_path + "/" + script
			var _btn := category.add_command_button(command_name)
			_btn.pressed.connect(_on_command_selected.bind(script_path))


func _on_command_selected(p_script_path: String):
	var script := load(p_script_path) as Script
	if script == null:
		printerr("Failed to load script from %s" % p_script_path)
		return
	
	var command_instance := script.new() as Command
	if command_instance != null:
		command_added.emit(command_instance)
