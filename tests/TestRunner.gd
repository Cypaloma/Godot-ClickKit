extends Node

func _ready() -> void:
	print("Starting Integration Tests...")
	await get_tree().process_frame
	await get_tree().process_frame
	
	_test_initial_state()
	await _test_navigation()
	
	print("All tests passed!")
	get_tree().quit(0)

func _test_initial_state() -> void:
	var main = _get_main_node()
	if not main:
		_fail("Could not find Main node")
		return
		
	if GameState.current_room_id != &"bedroom":
		_fail("Initial room should be 'bedroom', got '%s'" % GameState.current_room_id)
		return
	else:
		print("PASS: Initial room is bedroom")

func _test_navigation() -> void:
	var main = _get_main_node()
	
	# Find the hotspot
	var room = main.room_container.get_child(0)
	var hotspot = room.get_node("BookshelfHotspot")
	if not hotspot:
		_fail("Could not find BookshelfHotspot")
		return
		
	print("Simulating click on BookshelfHotspot...")
	hotspot._activate()
	
	# Wait for transition (0.5s out + 0.5s in + buffer)
	await get_tree().create_timer(1.2).timeout
	
	if GameState.current_room_id != &"bookshelf":
		_fail("Room should be 'bookshelf', got '%s'" % GameState.current_room_id)
	else:
		print("PASS: Navigation to bookshelf successful")
		
	# Verify message (Bookshelf has a message too? No, it has target_room_id. Let's check the scene)
	# Bedroom_main.tscn: BookshelfHotspot -> target_room_id="bookshelf", message="You step closer..."
	
	if main.message_label.text != "You step closer to the bookshelf.":
		_fail("Message should be 'You step closer to the bookshelf.', got '%s'" % main.message_label.text)
	else:
		print("PASS: Message displayed correctly")

func _get_main_node() -> Main:
	return get_node("Main") as Main

func _fail(msg: String) -> void:
	push_error("FAIL: " + msg)
	print("FAIL: " + msg)
	get_tree().quit(1)
