extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_anything_pressed():
		# start next scene
		get_tree().change_scene_to_file("res://Scenes/test-area.tscn")
		pass
	pass


func _on_timer_timeout() -> void:
	# make the label blink/flash
	self.visible = !self.visible
	# self refers to the object the script is attached to
	# in this case the script is attached directly to the label
	pass
