extends TouchScreenButton
#Analog Horizontal Oval
var inputVector
var maxXDistance = 60
var minXDistance = -60
var stickCenter = Vector2(1.5, -39.75) # Our local 2D transform for center
var dragging_oval = false
var last_pos = stickCenter
var touch_index = -1 # -1 is no touch, because null might cause issues

@export var click_radius = 60
@export var rightMove = "ui_right"
@export var leftMove = "ui_left"

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		#print_debug("Input event position: " + str(event.position) + ", sprite position: " + str(self.global_position))
		if (event.position - self.global_position).length() < click_radius:
			touch_index = event.index # store our multitouch event index for identifying the touch
			# Start dragging if the click is on the sprite.
			if not dragging_oval and pressed:
				dragging_oval = true
				#print_debug("Stick pressed")

	if (event is InputEventScreenDrag) and (touch_index == event.index) and dragging_oval:
		# While dragging, move the sprite with the mouse.
		#position = event.position
		inputVector = event.screen_relative + last_pos
		if inputVector.x > maxXDistance:
			inputVector.x = maxXDistance
		if inputVector.x < minXDistance:
			inputVector.x = minXDistance
		
		inputVector.y = stickCenter.y
		last_pos = position
		position = inputVector
		
		var newInputEvent = InputEventAction.new() # Create our new input event to fire
		var inputStrength
		if inputVector.x > 0:
			newInputEvent.action = rightMove
			Input.action_release(leftMove) # Release old input
			inputStrength = inputVector.x / maxXDistance
		elif inputVector.x < 0:
			newInputEvent.action = leftMove
			Input.action_release(rightMove) # Release old input
			inputStrength = inputVector.x / minXDistance
		newInputEvent.strength = inputStrength
		#print_debug("Input: " + newInputEvent.action + " with a strength of: " + str(inputStrength))
		newInputEvent.pressed = true
		Input.parse_input_event(newInputEvent) # Send new input
	pass

func _released(): # We use the _released signal because the self.released is a constant and stays true forever after touch
	#print_debug("Oval released")
	# Reset visual joystick
	position = stickCenter
	last_pos = stickCenter
	# Stop dragging if the button is released.
	dragging_oval = false
	touch_index = -1
	# Zero virtual joystick
	Input.action_release(leftMove)
	Input.action_release(rightMove)
	return
