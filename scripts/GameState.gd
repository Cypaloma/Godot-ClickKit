## res://scripts/GameState.gd
## Minimal game state singleton with auto-save

extends Node

const SAVE_FILE: String = "user://autosave.cfg"

var current_room_id: StringName = &""

## Saves the current game state to disk
func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("game", "current_room_id", current_room_id)
	config.save(SAVE_FILE)

## Loads the game state from disk
## Returns true if a valid save was loaded
func load_game() -> bool:
	var config := ConfigFile.new()
	if config.load(SAVE_FILE) != OK:
		return false
	
	current_room_id = config.get_value("game", "current_room_id", &"")
	return current_room_id != &""
