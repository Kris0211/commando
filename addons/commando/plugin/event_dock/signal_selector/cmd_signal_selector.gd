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


func setup(signals: Array[Dictionary], current_signal: StringName) -> void:
	for i: int in signals.size():
		var _sig: Dictionary = signals[i]
		var signal_name: StringName = _sig.get("name")
		dropdown.add_item(signal_name, i)
		if current_signal == signal_name:
			dropdown.select(i)


func _on_option_button_item_selected(index: int) -> void:
	selection_changed.emit("signal_name", dropdown.get_item_text(index))
