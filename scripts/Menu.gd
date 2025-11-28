## res://scripts/Menu.gd
## Main Menu logic
extends Room

@onready var start_btn: Button = $CanvasLayer/CenterContainer/VBoxContainer/StartButton

func _ready() -> void:
	super._ready()
	# Connect button signal
	if start_btn:
		start_btn.pressed.connect(_on_start_pressed)

## Called when the Start Game button is pressed
func _on_start_pressed() -> void:
	SignalBus.request_change_room.emit(&"bedroom")
