extends Node3D

@export var follow_object:NodePath
@export var follow_speed:float
@export var invertX:bool = false
@export var invertY:bool = false
@export var capture_mouse: bool = false
@export var use_mouse_click: bool = false
@export var mouse_click_to_use: MouseButton = MOUSE_BUTTON_LEFT
@export var capture_joypad: bool = false
@export var use_touch_stick: bool = true
@export var max_x_rot: float = 45
@export var min_x_rot: float = -75

var follow:Node3D
var lookv:Vector2
var _mouse_clicked = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if capture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	follow = get_node(follow_object)
	pass # Replace with function body.


func _input(event):
	if (event is InputEventMouseButton) and (use_mouse_click):
		if (event.button_index == mouse_click_to_use):
			_mouse_clicked = event.pressed
	elif (event is InputEventMouseMotion):
		if (capture_mouse):
			lookv = event.velocity*0.00001
		elif (_mouse_clicked):
			lookv = event.screen_velocity*0.0001
		
	if !invertY: # yeah, it's technically reversed right now
		lookv.y = lookv.y*-1
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if ((use_touch_stick) or (capture_joypad)) and (lookv == Vector2.ZERO):
		# Capture if _input(event) didn't set it from mouse input, to allow both to work at once for some reason
		lookv = Input.get_vector("cam_left","cam_right","cam_down","cam_up")*0.1
		# This is a compatibility hack since the touch stick can be held but not fire _input(event) events
	
	if (rotation_degrees.x < max_x_rot) and (lookv.y < 0): # Look down
		rotate_object_local(Vector3.LEFT,lookv.y)
	elif (rotation_degrees.x > min_x_rot) and (lookv.y > 0): # Look up
		rotate_object_local(Vector3.LEFT,lookv.y)
	
	rotate_y(lookv.x if invertX else lookv.x*-1) # left/right

	if follow != null:
		var goto = follow.position+Vector3(0,1,0)
		position = position + ((goto-position)*delta*follow_speed)
	lookv = Vector2.ZERO
	pass
