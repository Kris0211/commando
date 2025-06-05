## A signal selector dropdown for event properties.
@tool
class_name CmdSignalSelector extends HBoxContainer

signal selection_changed(property_name: StringName, signal_name: StringName)


@onready var _label := $Label as Label
@onready var dropdown := $OptionButton as OptionButton


func _ready() -> void:
	dropdown.item_selected.connect(_on_option_button_item_selected)


func _exit_tree() -> void:
	dropdown.item_selected.disconnect(_on_option_button_item_selected)


func setup(source_node: Node, current_signal: StringName) -> void:
	dropdown.clear()
	var signals: Array[StringName] = _get_signals_by_depth(source_node, 
			Cmd.Config.max_inheritance_depth)
	for i: int in signals.size():
		var sig: StringName = signals[i]
		dropdown.add_item(sig, i)
		if sig == current_signal:
			dropdown.select(i)
	
	if !dropdown.has_selectable_items():
		dropdown.add_separator("<no signals found>")


func _get_signals_by_depth(node: Node, max_depth: int) -> Array[StringName]:
	var result: Array[StringName] = []
	var seen: Dictionary = {}
	
	var script: Script = node.get_script()
	if script != null:
		for sig in script.get_script_signal_list():
			var sig_name = sig.get("name")
			result.append(sig_name)
			seen[sig_name] = true
	
	if max_depth == 0:
		return result
	
	var current_class := node.get_class()
	var current_depth := 1
	while ClassDB.class_exists(current_class):
		var parent_class: StringName = ClassDB.get_parent_class(current_class)
		var current_signals: Array[Dictionary] = \
				ClassDB.class_get_signal_list(current_class)
		var parent_signals: Array[Dictionary] = []
		
		if ClassDB.class_exists(parent_class):
			parent_signals = ClassDB.class_get_signal_list(parent_class)
		
		# Extract signal names
		var parent_signal_names := parent_signals.map(
			func(sig: Dictionary): 
				return sig.get("name")
		)
		var current_only := current_signals.filter(
			func(sig: Dictionary): 
				return !parent_signal_names.has(sig.get("name"))
		)
		
		if current_only.size() > 0: # Skip classes with no signals
			for sig: Dictionary in current_only:
				var sig_name: StringName = sig.get("name")
				if !seen.has(sig_name):
					result.append(sig_name)
					seen[sig_name] = true
			
			if max_depth > 0 && current_depth >= max_depth:
				break
			
			current_depth += 1
		
		current_class = ClassDB.get_parent_class(current_class)
	
	return result


func _on_option_button_item_selected(index: int) -> void:
	selection_changed.emit("signal_name", dropdown.get_item_text(index))
