# Commando  
***Commando*** is a plugin that helps designers create and manage in-game events using lightweight, visual commands. Inspired by RPG Maker Event Editor, it provides a block-based interface that facilitates designing complex behaviors - including conditions, branching, loops, global/local variables, and more. Use the built-in commands or extend the system by creating custom commands with GDScript.
## Features
- **Block-based event system** - Designers can create event logic using the visual editor - without having to write a single line of code.
- **Extendable for programmers** - Add your own, reusable commands or define new behavior in GDScript using *Custom Commands* where needed.
- **Built-in commands** - Includes flow control (branches/loops), variable manipulation, and actions such as instantiating scenes, moving objects in-game or playing animations.
- **Editor integration** - Seamlessly integrated with the Godot editor as a dock (or floating window)
- **Easily configurable** - Adjust your preferences using a config file - no need to follow rigid directory structure or modify source code to integrate the plugin with your existing codebase.
- **Drag-and-drop support** - Arrange your commands by simply dragging and dropping widgets.
- **Cut-copy-paste operations** - Duplicate or move commands between events by using keyboard shortcuts or the right-click context menu.
### Use Cases
- **Interactive dialogues** - Animations, sound effects, camera movements...
- **Puzzle mechanics** - Set conditions and actions for puzzle logic.
- **RPG Events** - Create in-game cutscenes, define NPC actions, and manage quest triggers.
- And more!
## User Guide
### Installation
1. Download code as ZIP or clone the repository.
2. Move the `addons/commando` folder into your Godot project.
3. Enable the plugin in **Project Settings > Plugins**.

### Creating an Event
1. Add a `GameEvent` node to the scene.
2. Open the *GameEvent* dock in the editor.
3. Select your event node and add commands using provided interface.
4. Trigger the event in-game with `execute()`.

### Using GameEvent without code
1. Select a `GameEvent` node from your scene.
2. Using Inspector, pick whether you want the event to execute on ready or on signal.
3. If using signal trigger, select signal source node and signal name.

### Creating new Commands  
Programmers can define new commands in GDScript that designers can later use without writing a single line of code. This makes event scripting highly **reusable** and **collaborative**.
1. Inherit from `Command.gd`.
2. Implement `execute()` with your custom behavior.
3. Add it to the project and let designers use it in Commando!

### Using "Custom Command"
If a one-time behavior is needed, designers can use the **"Custom Command"** widget. This works exactly as if you were to create a new command, but it does not clutter the "Add New Command" window. Simply select a script or create a new one!
*Currently Custom Commands do not expose their exported properties to Commando, unlike regular Commands.*

**Example Custom Command:**
```gdscript
extends Command

# Let's say your game uses a "Game" singleton that has a "get_player" method.
var player := Game.get_player() 

func execute(_event: GameEvent) -> void:
    print("Custom behavior of event %s here!" % _event.name)
    if not player.has_cookies():
	    print("You have no cookies! Here, have some!")
	    player.add_cookies(1)
    finished.emit()  # Always emit `finished` when done.
```

## License 
This project is licensed under the **MIT License**.

## Contributing
Contributions are welcome! If you find a bug, need a feature, or want to improve the plugin, submit an issue or open a pull request.
