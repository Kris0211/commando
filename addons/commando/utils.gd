## Helper library containing static utility functions.
@tool
class_name CmdUtils extends Node

## Shows a generic popup with one "OK" button.
static func show_popup(_dialog: String, _label: String = "Alert!") -> void:
	var popup_window := AcceptDialog.new()
	
	popup_window.set_hide_on_ok(false)
	popup_window.set_initial_position(
			Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS)
	popup_window.set_title(_label)
	popup_window.set_text(_dialog)
	
	popup_window.confirmed.connect(
		func(): popup_window.call_deferred(&"free")
	)
	popup_window.canceled.connect(
		func(): popup_window.call_deferred(&"free")
	)
	
	EditorInterface.get_base_control().add_child(popup_window)
	popup_window.popup()


## Shows a confirmation popup with an "OK" button and a "Cancel" button.
## The returned reference can be used to connect signals.
static func show_confirm_popup(_dialog: String, 
		_label: String = "Alert!") -> ConfirmationDialog:
	var popup_window := ConfirmationDialog.new()
	
	popup_window.set_hide_on_ok(false)
	popup_window.set_initial_position(
			Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS)
	popup_window.set_title(_label)
	popup_window.set_text(_dialog)
	
	popup_window.confirmed.connect(
		func(): popup_window.call_deferred(&"free")
	)
	popup_window.canceled.connect(
		func(): popup_window.call_deferred(&"free")
	)
	
	EditorInterface.get_base_control().add_child(popup_window)
	popup_window.popup()
	
	return popup_window


## Creates and pops up a customizable [EditorFileDialog].
## The returned reference can be used to connect signals.
static func show_file_dialog(
	dir: String = "res://", 
	filters: PackedStringArray = [],
	file_mode: EditorFileDialog.FileMode = EditorFileDialog.FILE_MODE_OPEN_FILE,
	access: EditorFileDialog.Access = EditorFileDialog.ACCESS_RESOURCES, 
	size: Vector2i = Vector2i(1200, 800)
) -> EditorFileDialog:
	var file_dialog := EditorFileDialog.new()
	
	file_dialog.set_access(access)
	file_dialog.set_file_mode(file_mode)
	file_dialog.set_initial_position(
			Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS)
	file_dialog.set_size(size)
	file_dialog.set_current_dir(dir)
	file_dialog.set_filters(filters)
	
	file_dialog.close_requested.connect(
		func(): file_dialog.call_deferred(&"free")
	)
	
	EditorInterface.get_base_control().add_child(file_dialog)
	file_dialog.popup()
	return file_dialog


## Saves data to file.
static func save_file(resource: Resource, path: String) -> Error:
	var err: Error = ResourceSaver.save(resource, path)
	if err != OK:
		CmdUtils.show_popup.call_deferred("Error code %s: %s" % \
				[err, error_string(err)])
	return err


## Prints a message to stdout only in editor/debug builds.
static func log_debug(message: String) -> void:
	if OS.is_debug_build() || OS.has_feature("editor"):
		print_debug(message)
