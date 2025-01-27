extends TouchScreenButton
#Analog Stick
var inputVector
var maxDistance = 60
var minDistance = -60
var stickCenter = Vector2(0, 0) # Our local 2D transform for center
var dragging_stick = false
var last_pos = stickCenter
var touch_index = -1 # -1 is no touch, because null might cause issues

@export var click_radius = 80

func _input(event: InputEvent) -> void:
	var _eventText = event.as_text()
	if (event is InputEventScreenTouch):
		#print_debug("Input event position: " + str(event.position) + ", sprite position: " + str(self.global_position))
		if (event.position - self.global_position).length() < click_radius:
			touch_index = event.index # store our multitouch event index for identifying the touch
			
			# Start dragging if the click is on the sprite.
			if not dragging_stick:
				dragging_stick = true
				#print_debug("Stick pressed")

	if (event is InputEventScreenDrag) and (touch_index == event.index):
		# While dragging, move the sprite with the mouse.
		#position = event.position
		
		#print_debug("event.screen_relative: " + str(event.screen_relative) + ", last_pos: " + str(last_pos))
		inputVector = event.screen_relative + last_pos
		
		if inputVector.x > maxDistance:
			inputVector.x = maxDistance
		if inputVector.y > maxDistance:
			inputVector.y = maxDistance
			
		if inputVector.x < minDistance:
			inputVector.x = minDistance
		if inputVector.y < minDistance:
			inputVector.y = minDistance
			
		#print_debug("Stick input vector: " + str(inputVector))
		last_pos = position
		position = inputVector
		
		var newInputEventJoyX = InputEventJoypadMotion.new() # Craft our input event for JoyX
		newInputEventJoyX.axis = JOY_AXIS_LEFT_X
		newInputEventJoyX.axis_value = inputVector.x / maxDistance
		var newInputEventJoyY = InputEventJoypadMotion.new() # Craft our input event for JoyY
		newInputEventJoyY.axis = JOY_AXIS_LEFT_Y
		newInputEventJoyY.axis_value = inputVector.y / maxDistance
		#print_debug("Input: joy axis y" + " with a strength of: " + str(inputVector.y / maxDistance))
		#print_debug("Input: joy axis x" + " with a strength of: " + str(inputVector.x / maxDistance))
		Input.parse_input_event(newInputEventJoyX) # Fire input event
		Input.parse_input_event(newInputEventJoyY) # Fire input event
	pass
	
func _released(): # We use the _released signal because the self.released is a constant and stays true forever after touch
	if (dragging_stick):
		# Recenter stick
		position = stickCenter
		last_pos = stickCenter
		# Stop dragging if the button is released.
		dragging_stick = false
		touch_index = -1
		#print_debug("Stick released [1]")
		# Zero virtual joystick
		var newInputEventJoyX = InputEventJoypadMotion.new()
		newInputEventJoyX.axis = JOY_AXIS_LEFT_X
		newInputEventJoyX.axis_value = 0.0
		var newInputEventJoyY = InputEventJoypadMotion.new()
		newInputEventJoyY.axis = JOY_AXIS_LEFT_Y
		newInputEventJoyY.axis_value = 0.0
		Input.parse_input_event(newInputEventJoyX)
		Input.parse_input_event(newInputEventJoyY)
		return
