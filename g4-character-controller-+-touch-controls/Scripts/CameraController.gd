extends Node3D

@export var follow_object:NodePath
@export var follow_speed:float
@export var invertX:bool = false
@export var invertY:bool = false
@export var capture_mouse: bool = false
@export var capture_joypad: bool = false
@export var use_touch_stick: bool = true

var follow:Node3D
var lookv:Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	if capture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	follow = get_node(follow_object)
	pass # Replace with function body.


func _input(event):
	if (event is InputEventMouseMotion) and capture_mouse:
		lookv = Input.get_last_mouse_velocity()*0.00001
	if (event is InputEventJoypadMotion) and capture_joypad:
		lookv = Input.get_vector("cam_left","cam_right","cam_up","cam_down")*0.1
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if use_touch_stick:
		lookv = Input.get_vector("cam_left","cam_right","cam_up","cam_down")*0.1
	
	rotate_y(lookv.x if invertX else lookv.x*-1)
	rotate_object_local(Vector3.LEFT,(lookv.y if invertY else lookv.y*-1))
	rotation.x = clamp(rotation.x, -15, 15)
	
	if follow != null:
		var goto = follow.position+Vector3(0,1,0)
		position = position + ((goto-position)*delta*follow_speed)
	lookv = Vector2.ZERO
	pass
