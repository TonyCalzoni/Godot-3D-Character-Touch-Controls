extends AnimationTree

var last_state:PlayerCharacterController.state

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func state_changed(new_state:PlayerCharacterController.state):
	if new_state == PlayerCharacterController.state.FALL:
		set("parameters/Air/blend_amount", 1.0)
	if new_state == PlayerCharacterController.state.JUMP:
		set("parameters/Air/blend_amount", 1.0)
		set("parameters/JumpStart/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	if new_state == PlayerCharacterController.state.RUN:
		set("parameters/Run/blend_amount", 1.0)
	if new_state == PlayerCharacterController.state.IDLE:
		# bug fix for removing _process()
		set("parameters/Air/blend_amount", 0.0)
		set("parameters/Run/blend_amount", 0.0)
	last_state = new_state
