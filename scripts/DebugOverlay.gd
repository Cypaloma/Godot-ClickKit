## res://scripts/DebugOverlay.gd
## Debug visualization overlay for hotspots and room information

extends CanvasLayer

var debug_enabled: bool = false
var _current_room: Room = null
var _debug_shapes: Array[Control] = []

@onready var info_panel: PanelContainer = $InfoPanel
@onready var info_label: Label = $InfoPanel/InfoLabel

func _ready() -> void:
	# Setup UI
	layer = 100  # Always on top
	info_panel.hide()
	
	# Connect to room changes
	SignalBus.request_change_room.connect(_on_room_changing)
	
	print("DebugOverlay: Ready! Press F12 to toggle debug mode.")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F12 or event.physical_keycode == KEY_F12:
			print("DebugOverlay: F12 detected via _input!")
			debug_enabled = !debug_enabled
			_update_debug_display()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("toggle_debug"):
			print("DebugOverlay: toggle_debug action detected!")
			debug_enabled = !debug_enabled
			_update_debug_display()
			get_viewport().set_input_as_handled()

## Updates the debug display based on current state
func _update_debug_display() -> void:
	if debug_enabled:
		_show_debug_info()
	else:
		_hide_debug_info()

## Shows debug visualization
func _show_debug_info() -> void:
	info_panel.show()
	_refresh_room_info()
	_draw_hotspot_overlays()

## Hides all debug visualization
func _hide_debug_info() -> void:
	info_panel.hide()
	_clear_hotspot_overlays()

## Refreshes the room information panel
func _refresh_room_info() -> void:
	if not _current_room:
		info_label.text = "No room loaded"
		return
	
	var info_text = "[b]Debug Mode (F12 to toggle)[/b]\n"
	info_text += "Room ID: %s\n" % _current_room.room_id
	info_text += "Parent Room: %s\n" % (_current_room.parent_room_id if _current_room.parent_room_id != &"" else "None")
	
	# List hotspots
	var hotspots = _get_hotspots_in_room()
	info_text += "\n[b]Hotspots (%d):[/b]\n" % hotspots.size()
	for hotspot in hotspots:
		var status = "✓" if hotspot.enabled else "✗"
		var target = hotspot.target_room_id if hotspot.target_room_id != &"" else "(no target)"
		info_text += "%s %s → %s\n" % [status, hotspot.id, target]
	
	info_label.text = info_text

## Draws colored overlays over all hotspots
func _draw_hotspot_overlays() -> void:
	_clear_hotspot_overlays()
	
	var hotspots = _get_hotspots_in_room()
	for hotspot in hotspots:
		var overlay = _create_hotspot_overlay(hotspot)
		if overlay:
			add_child(overlay)
			_debug_shapes.append(overlay)
			
	# Draw mouse crosshair for cursor debugging
	var crosshair = _create_crosshair()
	add_child(crosshair)
	_debug_shapes.append(crosshair)

## Creates a crosshair at mouse position
func _create_crosshair() -> Control:
	var crosshair = Control.new()
	crosshair.name = "DebugCrosshair"
	
	# Horizontal line
	var h_line = ColorRect.new()
	h_line.size = Vector2(20, 2)
	h_line.position = Vector2(-10, -1)
	h_line.color = Color.RED
	crosshair.add_child(h_line)
	
	# Vertical line
	var v_line = ColorRect.new()
	v_line.size = Vector2(2, 20)
	v_line.position = Vector2(-1, -10)
	v_line.color = Color.RED
	crosshair.add_child(v_line)
	
	# Update position every frame
	var script = GDScript.new()
	script.source_code = "extends Control\nfunc _process(_delta):\n\tglobal_position = get_global_mouse_position()"
	script.reload()
	crosshair.set_script(script)
	
	return crosshair

## Creates a visual overlay for a single hotspot
func _create_hotspot_overlay(hotspot: Hotspot) -> Control:
	var collision_shape = hotspot.get_node_or_null("CollisionShape2D")
	if not collision_shape or not collision_shape.shape:
		return null
	
	var overlay = ColorRect.new()
	
	# Calculate global position and size
	var global_pos = hotspot.global_position
	var shape = collision_shape.shape
	
	if shape is RectangleShape2D:
		var rect_shape = shape as RectangleShape2D
		var size = rect_shape.size * hotspot.scale
		var shape_offset = collision_shape.position * hotspot.scale
		
		overlay.position = global_pos + shape_offset - size / 2
		overlay.size = size
	else:
		# Fallback for other shape types
		overlay.position = global_pos
		overlay.size = Vector2(50, 50)
	
	# Color based on state
	if hotspot.enabled:
		overlay.color = Color(0, 1, 0, 0.3)  # Green for enabled
	else:
		overlay.color = Color(1, 0, 0, 0.3)  # Red for disabled
	
	# Add label
	var label = Label.new()
	label.text = String(hotspot.id)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(5, 5)
	overlay.add_child(label)
	
	return overlay

## Clears all hotspot overlays
func _clear_hotspot_overlays() -> void:
	for shape in _debug_shapes:
		shape.queue_free()
	_debug_shapes.clear()

## Gets all hotspots in the current room
func _get_hotspots_in_room() -> Array[Hotspot]:
	var hotspots: Array[Hotspot] = []
	if not _current_room:
		return hotspots
	
	for child in _current_room.get_children():
		if child is Hotspot:
			hotspots.append(child)
	
	return hotspots

## Updates current room reference
func set_current_room(room: Room) -> void:
	_current_room = room
	if debug_enabled:
		_update_debug_display()

## Called when room is changing
func _on_room_changing(_target_room_id: StringName) -> void:
	_current_room = null
	if debug_enabled:
		_clear_hotspot_overlays()
