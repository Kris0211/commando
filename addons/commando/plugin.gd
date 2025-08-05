@tool
class_name Cmd extends EditorPlugin

const EVENT_DOCK := \
		preload("res://addons/commando/plugin/event_dock/cmd_event_dock.tscn")

var event_dock_instance: EditorCmdEventDock = null

static var Config: DockConfig


func _enter_tree():
	# Register event editor dock
	event_dock_instance = EVENT_DOCK.instantiate()
	event_dock_instance.set_script_create_dialog(get_script_create_dialog())
	Config = DockConfig.new()
	Config.load_config()
	add_control_to_dock(self.Config.dock_slot, event_dock_instance)


func _exit_tree():
	if event_dock_instance != null:
		remove_control_from_docks(event_dock_instance)
		event_dock_instance.free()


class DockConfig:
	const CONFIG_PATH := "res://addons/commando/dock.cfg"
	const ERROR_MSG := \
			"Failed to load dock config from path '%s'! Using default values."
	var _config := ConfigFile.new()
#region CONFIG-VALUES
	var colors: Dictionary = {}
	var category_order: PackedStringArray = []
	var excluded_dirs: PackedStringArray = []
	var excluded_prefix: String = "_"
	var command_root_dir: String = "res://addons/commando/commands/"
	var command_icons_dir: String = "res://addons/commando/icons/"
	var default_command_icon: String = "res://addons/commando/icons/command.svg"
	var float_step: float = 0.01
	var dock_slot: int = EditorPlugin.DockSlot.DOCK_SLOT_RIGHT_UL
	var use_category_colors: bool = true
	var display_enum_values: bool = false
	var max_inheritance_depth: int = 1
	var show_type_selector: bool = true
#endregion
	
	func load_config() -> void:
		if _config.load(CONFIG_PATH) != OK:
			printerr(ERROR_MSG % CONFIG_PATH)
			return
		
		# General settings
		command_root_dir = _config.get_value("General",
				"command_root_dir", "res://addons/commando/commands/")
		command_icons_dir = _config.get_value("General",
				"command_icons_dir", "res://addons/commando/icons/")
		default_command_icon = _config.get_value("General",
				"default_command_icon", "res://addons/commando/icons/command.svg")
		display_enum_values = _config.get_value("General",
				"display_enum_values", false)
		dock_slot = _config.get_value("General",
				 "dock_slot", EditorPlugin.DockSlot.DOCK_SLOT_RIGHT_UL)
		excluded_prefix = _config.get_value("General",
				"excluded_prefix", "_")
		float_step = _config.get_value("General",
				"float_step", 0.01)
		use_category_colors = _config.get_value("General",
				"use_category_colors", true)
		max_inheritance_depth = _config.get_value("General",
				"max_inheritance_depth", 1)
		show_type_selector = _config.get_value("General",
				"show_type_selector", true)
		
		# Excluded dirs
		excluded_dirs.clear()
		var excluded_keys := _config.get_section_keys("ExcludedDirectories")
		for key in excluded_keys:
			var excluded_dir = _config.get_value("ExcludedDirectories", 
					key, "")
			excluded_dirs.append(excluded_dir)
		
		# Category order
		category_order.clear()
		var cat_keys := _config.get_section_keys("CategoryOrder")
		for key in cat_keys:
			var category = _config.get_value("CategoryOrder", 
					key, "")
			category_order.append(category)
		
		# Colors
		colors.clear()
		colors["default"] = Color("#40484c") # Add default value
		var color_keys := _config.get_section_keys("Colors")
		for key in color_keys:
			var color_hex: String = _config.get_value("Colors", 
					key, "#40484c")
			colors[key] = Color(color_hex)
