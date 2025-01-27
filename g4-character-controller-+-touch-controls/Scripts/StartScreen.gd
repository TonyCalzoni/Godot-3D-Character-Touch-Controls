extends Label

func load_game() -> void:
	# start next scene
	get_tree().change_scene_to_file("res://Scenes/test-area.tscn")
	self.queue_free() # remove current node and attached script (this script)
	return

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch) or (event is InputEventScreenTouch) or (Input.is_anything_pressed()):
		load_game()

func _on_timer_timeout() -> void:
	# make the label blink/flash
	self.visible = !self.visible
	# self refers to the object the script is attached to
	# in this case the script is attached directly to the label
	pass
