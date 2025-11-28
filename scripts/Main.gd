## res://scripts/Main.gd
## Main game controller for minimal point-and-click framework

class_name Main
extends Node2D

@export_group("Configuration")
@export_dir var rooms_directory: String = "res://demo/rooms"
@export var starting_room_id: StringName = &""
@export var transition_duration: float = 0.5
@export var background_image: Texture2D = null

@export_group("Cursors")
@export_subgroup("Default")
@export var cursor_default: Texture2D = null
@export var cursor_default_hotspot: Vector2 = Vector2.ZERO

@export_subgroup("Hover")
@export var cursor_hover: Texture2D = null
@export var cursor_hover_hotspot: Vector2 = Vector2.ZERO

@onready var background_rect: TextureRect = $BackgroundLayer/BackgroundRect
@onready var room_container: Node2D = $RoomContainer
@onready var message_panel: PanelContainer = $UILayer/MessagePanel
@onready var message_label: Label = $UILayer/MessagePanel/MessageLabel
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var transition_overlay: CanvasModulate = $TransitionOverlay
@onready var debug_overlay: CanvasLayer = $DebugOverlay

var _current_music: AudioStream = null
var _active_tween: Tween
var _rooms: Dictionary = {}  # Auto-populated from rooms_directory

func _ready() -> void:
	# Setup Background
	if background_image:
		background_rect.texture = background_image
		background_rect.show()
	else:
		background_rect.hide()
	
	# Setup Custom Cursors
	if cursor_default:
		Input.set_custom_mouse_cursor(cursor_default, Input.CURSOR_ARROW, cursor_default_hotspot)
	if cursor_hover:
		Input.set_custom_mouse_cursor(cursor_hover, Input.CURSOR_POINTING_HAND, cursor_hover_hotspot)
	
	# Setup UI
	message_panel.hide()
	
	# Connect Signals
	SignalBus.request_change_room.connect(_change_room)
	SignalBus.request_show_message.connect(_show_message)
	SignalBus.request_play_sfx.connect(_play_sfx)
	SignalBus.hotspot_hover_changed.connect(_on_hotspot_hover)
	
	# Auto-discover rooms
	_discover_rooms()
	
	# Load starting room
	if starting_room_id != &"" and _rooms.has(starting_room_id):
		print("Main: Loading starting room '%s'" % starting_room_id)
		_load_room(starting_room_id)
	else:
		var available = ", ".join(_rooms.keys())
		var error_msg = "FATAL ERROR: Starting room '%s' not found!\nAvailable rooms: %s" % [starting_room_id, available]
		push_error("Main: " + error_msg)
		_show_error(error_msg)

## Auto-discovers all room scenes in the configured directory
func _discover_rooms() -> void:
	if not DirAccess.dir_exists_absolute(rooms_directory):
		push_error("Main: Rooms directory '%s' does not exist!" % rooms_directory)
		return
	
	var dir = DirAccess.open(rooms_directory)
	if not dir:
		push_error("Main: Could not open rooms directory '%s'" % rooms_directory)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var room_path = rooms_directory.path_join(file_name)
			var room_scene = load(room_path) as PackedScene
			
			if room_scene:
				# Instantiate temporarily to get room_id
				var temp_room = room_scene.instantiate() as Room
				if temp_room:
					# Generate the room's ID (same logic as Room._generate_room_id)
					var room_id: StringName
					if temp_room.room_id_override != &"":
						room_id = temp_room.room_id_override
					else:
						room_id = StringName(file_name.get_basename())
					
					if _rooms.has(room_id):
						push_warning("Main: Duplicate room ID '%s' found in '%s'. Overwriting previous room." % [room_id, file_name])
					
					_rooms[room_id] = room_scene
					temp_room.queue_free()
				else:
					push_warning("Main: Scene '%s' is not a Room" % file_name)
			else:
				push_warning("Main: Could not load scene '%s'" % file_name)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	print("Main: Discovered %d rooms: %s" % [_rooms.size(), ", ".join(_rooms.keys())])

## Changes the current room to the target room ID
## Handles transition effects and scene instantiation
func _change_room(target_room_id: StringName) -> void:
	if _active_tween and _active_tween.is_running():
		return

	if not _rooms.has(target_room_id):
		var available = ", ".join(_rooms.keys())
		var error_msg = "Room '%s' not found!\nAvailable rooms: %s" % [target_room_id, available]
		push_error("Main: " + error_msg)
		_show_error(error_msg)
		return

	# Transition Out
	if _active_tween: _active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(transition_overlay, "color", Color.BLACK, transition_duration)
	await _active_tween.finished
	
	_load_room(target_room_id)
	
	# Transition In
	_active_tween = create_tween()
	_active_tween.tween_property(transition_overlay, "color", Color.WHITE, transition_duration)

## Internal method to load a room scene and setup state
func _load_room(room_id: StringName) -> void:
	print("Main: _load_room called with room_id='%s'" % room_id)
	
	# Cleanup old room
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	for child in room_container.get_children():
		if child is Room:
			child._on_room_exited()
		child.queue_free()
	
	# Instantiate new room
	var room_scene: PackedScene = _rooms[room_id]
	var new_room := room_scene.instantiate() as Room
	
	print("Main: Adding room '%s' to scene tree" % room_id)
	room_container.add_child(new_room)
	GameState.current_room_id = room_id
	GameState.save_game()
	print("Main: Successfully loaded room '%s'" % room_id)
	
	# Handle Music
	if new_room.music_stream != _current_music:
		_crossfade_music(new_room.music_stream)
	
	new_room._on_room_entered()
	
	# Update debug overlay
	if debug_overlay:
		debug_overlay.set_current_room(new_room)

## Displays a message in the UI overlay
func _show_message(text: String) -> void:
	message_label.text = text
	message_panel.visible = not text.is_empty()

## Plays a sound effect
func _play_sfx(stream: AudioStream) -> void:
	if stream:
		sfx_player.stream = stream
		sfx_player.play()

## Updates the cursor shape based on hotspot hover state
func _on_hotspot_hover(is_hovering: bool) -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND if is_hovering else Input.CURSOR_ARROW)

## Displays an error message in a prominent red panel
func _show_error(error_text: String) -> void:
	message_label.text = "⚠️ ERROR ⚠️\n" + error_text
	message_panel.show()
	# Make it red to indicate error
	if message_panel.has_theme_stylebox_override("panel"):
		var stylebox = message_panel.get_theme_stylebox("panel").duplicate()
		if stylebox is StyleBoxFlat:
			stylebox.bg_color = Color(0.8, 0.2, 0.2, 0.9)
		message_panel.add_theme_stylebox_override("panel", stylebox)

## Smoothly crossfades between music tracks
func _crossfade_music(new_stream: AudioStream) -> void:
	# Fade out
	if music_player.playing:
		var fade_out = create_tween()
		fade_out.tween_property(music_player, "volume_db", -80.0, 0.5)
		await fade_out.finished
	
	_current_music = new_stream
	
	# Fade in
	if _current_music:
		music_player.stream = _current_music
		music_player.volume_db = -80.0
		music_player.play()
		var fade_in = create_tween()
		fade_in.tween_property(music_player, "volume_db", 0.0, 0.5)
	else:
		music_player.stop()
