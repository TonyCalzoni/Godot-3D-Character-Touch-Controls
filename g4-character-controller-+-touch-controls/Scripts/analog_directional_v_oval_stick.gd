extends TouchScreenButton
#Analog Vertical Oval
var inputVector
var maxYDistance = 60
var minYDistance = -60
var stickCenter = Vector2(-38.5, 0.25)  # Our local 2D transform for center
var dragging_oval = false
var click_radius = 120
var last_pos = stickCenter

@export var upMove = "ui_up"
@export var downMove = "ui_down"

func _input(event: InputEvent) -> void: #adjust this one, it's copied from the other
	if event is InputEventScreenTouch:
		#print_debug("Input event position: " + str(event.position) + ", sprite position: " + str(self.global_position))
		if (event.position - self.global_position).length() < click_radius:
			# Start dragging if the click is on the sprite.
			if not dragging_oval and pressed:
				dragging_oval = true
				#print_debug("Oval pressed")

	if (event is InputEventScreenDrag) and dragging_oval:
		# While dragging, move the sprite with the mouse.
		#position = event.position
		
		inputVector = event.screen_relative + last_pos
		#print_debug("last_pos.y: " + str(last_pos.y))
		if inputVector.y > maxYDistance:
			inputVector.y = maxYDistance
		if inputVector.y < minYDistance:
			inputVector.y = minYDistance
		
		inputVector.x = stickCenter.x
		#print_debug("Oval input vector y: " + str(inputVector.y))
		last_pos = position
		position = inputVector
		
		var newInputEvent = InputEventAction.new() # Create our new input event to fire
		var inputStrength
		if inputVector.y < 0:
			newInputEvent.action = upMove
			Input.action_release(downMove) # Release old input
			inputStrength = inputVector.y / minYDistance
		elif inputVector.y > 0:
			newInputEvent.action = downMove
			Input.action_release(upMove) # Release old input
			inputStrength = inputVector.y / maxYDistance
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
	# Zero virtual joystick
	Input.action_release(upMove)
	Input.action_release(downMove)
	pass
