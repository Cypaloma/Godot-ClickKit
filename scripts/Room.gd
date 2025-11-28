## res://scripts/Room.gd
## Base class for all rooms with auto-ID generation and intelligent back button support

class_name Room
extends Node2D

@export_group("Room Identity")
## Optional override for room ID. If empty, ID is auto-generated from filename.
## Example: Leave empty for "bedroom.tscn" → "bedroom", or set to customize.
@export var room_id_override: StringName = &""

@export_group("Navigation")
## If set, creates an automatic back button at the bottom of the screen.
## Set this to the parent room's ID to enable easy sub-room navigation.
@export var parent_room_id: StringName = &""
## Height of the back button bar as a percentage of screen height (0.0-1.0).
## Default 0.2 = 20% of screen height. Scales intelligently with resolution.
@export_range(0.0, 1.0) var back_bar_height_percent: float = 0.2

@export_group("Audio")
@export var music_stream: AudioStream = null

## Auto-generated or overridden room ID
var room_id: StringName = &""

## Called when the room enters the scene tree.
## Automatically scales the background and hotspots, generates room ID, and creates back button if needed.
func _ready() -> void:
	# Generate room ID
	_generate_room_id()
	
	# Scale background
	var background = get_node_or_null("Background")
	if background and background is Sprite2D and background.texture:
		var viewport_size = get_viewport_rect().size
		var tex_size = background.texture.get_size()
		var scale_x = viewport_size.x / tex_size.x
		var scale_y = viewport_size.y / tex_size.y
		background.scale = Vector2(scale_x, scale_y)
		
		# Scale all existing hotspots to match background scaling
		var scale_factor = Vector2(scale_x, scale_y)
		for child in get_children():
			if child is Hotspot:
				child.scale = scale_factor
	
	# Create back button if parent room is set
	if parent_room_id != &"":
		_create_back_button()

## Generates the room ID from filename or uses override
func _generate_room_id() -> void:
	if room_id_override != &"":
		room_id = room_id_override
	else:
		# Extract filename without path and extension
		var scene_path = scene_file_path
		var filename = scene_path.get_file().get_basename()
		room_id = StringName(filename)

## Creates an automatic full-width back button at the bottom of the screen
func _create_back_button() -> void:
	var viewport_size = get_viewport_rect().size
	var bar_height = viewport_size.y * back_bar_height_percent
	var bar_y_position = viewport_size.y - bar_height
	
	# Create back hotspot
	var back_hotspot = Hotspot.new()
	back_hotspot.name = "AutoBackButton"
	back_hotspot.id = &"auto_back"
	back_hotspot.target_room_id = parent_room_id
	back_hotspot.message = ""
	back_hotspot.position = Vector2(0, bar_y_position)
	back_hotspot.z_index = -1 # Ensure it's behind user-placed hotspots (priority)
	
	# Create collision shape
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(viewport_size.x, bar_height)
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2(viewport_size.x / 2, bar_height / 2)
	
	back_hotspot.add_child(collision_shape)
	add_child(back_hotspot)

# Override these in derived scripts if needed

## Called when the room is fully loaded and transition is complete
func _on_room_entered() -> void:
	pass

## Called just before the room is removed
func _on_room_exited() -> void:
	pass
