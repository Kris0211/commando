## Base interface for event Commands.
@icon("res://addons/icons/command/command.svg")
class_name Command extends Resource

## Emitted when this [Command] is done executing its logic.
## When creating custom commands, don't forget to emit this signal
## or else the game will get stuck on processing the command.
@warning_ignore("unused_signal")
signal finished

## Is this [Command] currently executing its logic?
var proceeding: bool

## Triggers this [Command] logic.
@warning_ignore("untyped_declaration")
func execute(_event):
	pass
