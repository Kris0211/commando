## Represents a command property editor for [NodePath]s.
@tool
extends EditorCmdCommandProperty

var _allowed_types: PackedStringArray = []

func _ready() -> void:
	property_editor = $Button as Button
	(property_editor as Button).pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	EditorInterface.popup_node_selector(set_property_value, _allowed_types)


## Sets property value. Value type is [NodePath].
func set_property_value(p_node_path: NodePath) -> void:
	if p_node_path.is_empty(): # On cancel, do nothing
		return
	
	var _root_node = EditorInterface.get_edited_scene_root()
	var resolved_path: NodePath
	if _root_node.has_node(p_node_path):
		resolved_path = _root_node.get_node(p_node_path).get_path()
	else:
		resolved_path = p_node_path
	
	var fetched_node := EditorCmdEventDock.event_node\
			.get_node_or_null(resolved_path)
	if fetched_node == null:
		printerr("Unable to fetch node using path: %s" % resolved_path)
		_clear_selection()
		return
	
	(property_editor as Button).set_text(fetched_node.get_name())
	(property_editor as Button).set_button_icon(_get_node_icon(fetched_node))
	
	property_changed.emit(_label.get_text(), 
			EditorCmdEventDock.event_node.get_path_to(fetched_node))


## Sets allowed [Node] types for selection.
func set_allowed_types(p_types: PackedStringArray) -> void:
	_allowed_types = p_types


func _find_event_root() -> Node:
	if EditorCmdEventDock.event_node != null:
		return EditorCmdEventDock.event_node.get_parent()
	# Fallback
	return EditorInterface.get_edited_scene_root().get_node(^"Events") 


func _clear_selection() -> void:
	(property_editor as Button).set_text("Assign...")
	(property_editor as Button).set_button_icon(null)


func _get_node_icon(p_node: Node) -> Texture2D:
	# Will return null if node has no icon (icon not set/not found)
	# or uses a custom @icon annotation.
	return EditorInterface.get_editor_theme().get_icon(
			p_node.get_class(), "EditorIcons")
