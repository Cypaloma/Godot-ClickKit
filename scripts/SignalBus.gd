## res://scripts/SignalBus.gd
## Global signal bus for event communication

extends Node

signal request_change_room(target_room_id: StringName)
signal request_show_message(text: String)
signal request_play_sfx(stream: AudioStream)
signal request_play_music(stream: AudioStream)
signal hotspot_hover_changed(is_hovering: bool)
