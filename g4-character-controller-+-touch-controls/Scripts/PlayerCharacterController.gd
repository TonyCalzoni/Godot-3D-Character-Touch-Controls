extends CharacterBody3D
class_name PlayerCharacterController

@export var base_health = 100
@export var jump_length:float = 0.5
@export var jump_power:float = 2000;
@export var gravity:float = 500
@export var runspeed:float = 5
@export var camera_object:NodePath
@export var air_run_time:float = 0.25

enum state{WALK,RUN,JUMP,FALL,IDLE,ATTACK}
@warning_ignore("unused_signal") # Silences the "UNUSED_SIGNAL" warning in debugger
signal change_state(state)

var camera:Node3D
var control_direction:Vector2 = Vector2(0,0)
var fallspeed = 0
var movement:Vector3 = Vector3(0,0,0)
var jumptime:float = 0
var last_facing:Vector2 = Vector2(0,1)
var current_state:state = state.IDLE
var previous_state:state = state.IDLE
var locked:Array = []
var last_on_floor:float = 0

#grab the camera so we can use it for relative movement
func _ready():
	camera = get_node(camera_object)

#Emit signals when we change player state
func _process(_delta):
	if current_state != previous_state:
		emit_signal("change_state",current_state)
		previous_state = current_state
		#print_debug("state changed to: " + str(current_state))

# unused
func reparent_node(from,to):
	var fnode = find_child(from,true,false)
	var tnode = find_child(to,true,false)
	if fnode.get_child_count() > 0:
		var moved = fnode.get_child(0)
		fnode.remove_child(moved)
		tnode.add_child(moved)
		return moved

func _do_input_movement(delta):
	#quit if escape (or pause button) is pressed
	if Input.is_action_just_pressed("ui_end") or Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	#zero movement out before we start
	movement = Vector3.ZERO;
	#get directional input
	if ! state.RUN in locked:
		control_direction = Input.get_vector("ui_right","ui_left","ui_down","ui_up")#*0.1
	#save that directional input in case we need it later
	if control_direction.length()>0.1:
		last_facing = control_direction
	#let's do horizontal movement!
	if control_direction.length()>0.1 and ! state.RUN in locked:
		rotation.y = (last_facing*Vector2(-1,1)).rotated(PI*1.5).angle()+camera.rotation.y
		var camera_relative = Vector3(0,0,runspeed*control_direction.length()).rotated(Vector3.UP,rotation.y)
		movement += camera_relative
		
	#jumping make go up
	if jumptime > 0:
		jumptime -= delta
		current_state = state.JUMP
		movement.y += jumptime*delta*jump_power
	#set the states for run/idle if we're not doing any of the other fancy stuff
	if is_on_floor():
		last_on_floor = 0
		fallspeed = 0;
		if control_direction.length()>0.1:
			current_state = state.RUN
		else:
			current_state = state.IDLE
		#do the actual movement
	else:
		#process falling, as long as we're not on the floor
		last_on_floor += delta
		fallspeed += gravity*delta
		current_state = state.FALL
		movement.y -= fallspeed*delta
	#get jump button input
	if Input.is_action_just_pressed("ui_accept") and ! state.JUMP in locked:
		if last_on_floor < air_run_time:
			jumptime = jump_length
	velocity = movement
	move_and_slide()


func _physics_process(delta):
	#don't do anythng till the camera is ready or we'll crash
	if camera == null:
		return
	_do_input_movement(delta)


#function to allow other systems to prevent certain kinds of movement
#that Array passed in needs to be string names of state enums eg "GLIDE"
#because I don't know how to specify an array of a particular enum
func lockout(new_locked:Array):
	locked.clear()
	for state_name in state.keys():
		if state_name in new_locked:
			locked.append(state[state_name])
	#print_debug(str(locked))
