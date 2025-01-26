extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var playerPrepack = preload("res://Scenes/player_container.tscn").instantiate()
	var touchControlsPrepack = preload("res://Scenes/touch_controls.tscn").instantiate()
	add_child(touchControlsPrepack)
	add_child(playerPrepack)
	pass # Replace with function body.
