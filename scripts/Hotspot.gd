## res://scripts/Hotspot.gd
## Simple interactive area for navigation and messages

class_name Hotspot
extends Area2D

@export var id: StringName = &""
@export var target_room_id: StringName = &""
@export_multiline var message: String = ""
@export var sfx: AudioStream = null
@export var enabled: bool = true

## Called when the node enters the scene tree
func _ready() -> void:
	# Ensure we can pick up input events
	input_pickable = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

## Handles input events on the hotspot area
func _input_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not enabled:
		return
	
	# Check if input was already handled by a higher priority hotspot
	if viewport.is_input_handled():
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		viewport.set_input_as_handled() # Consume the event so underlying hotspots don't react
		_activate()

## Triggers the hotspot's actions (SFX, Message, Room Change)
func _activate() -> void:
	if sfx:
		SignalBus.request_play_sfx.emit(sfx)
	
	if not message.is_empty():
		SignalBus.request_show_message.emit(message)
		
	if target_room_id != &"":
		SignalBus.request_change_room.emit(target_room_id)

## Emits hover signal when mouse enters
func _on_mouse_entered() -> void:
	if enabled:
		SignalBus.hotspot_hover_changed.emit(true)

## Emits hover signal when mouse exits
func _on_mouse_exited() -> void:
	SignalBus.hotspot_hover_changed.emit(false)
