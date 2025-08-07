## This class is meant to showcase how extending GameEvent
## allows for editing exported properties as "User Properties"
## in Commando Dock.
class_name UserEvent extends GameEvent

@export var user_id: int = 0xC4
@export var user_name: StringName = "Default User"

func execute() -> void:
	print("This does nothing!")
