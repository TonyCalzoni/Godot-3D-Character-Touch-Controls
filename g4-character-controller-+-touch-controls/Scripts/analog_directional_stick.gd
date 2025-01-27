extends TouchScreenButton
#Analog Stick
var inputVector
var stickCenter = Vector2(0, 0) # Our local 2D transform for center
var dragging_stick = false
var last_pos = stickCenter
var touch_index = -1 # -1 is no touch, because null might cause issues
var _pressed = false

@export var _joy_axis_x: JoyAxis = JOY_AXIS_LEFT_X
@export var _joy_axis_y: JoyAxis = JOY_AXIS_LEFT_Y
@export var click_radius = 70

func _process(_delta):
	if not _pressed:
		_released() # silly bug fix for sometimes not catching the release signal

func _input(event: InputEvent) -> void:
	var _eventText = event.as_text()
	if (event is InputEventScreenTouch):
		#print_debug("Input event position: " + str(event.position) + ", sprite position: " + str(self.global_position))
		if (event.position - self.global_position).length() < click_radius:
			# Start dragging if the click is on the sprite.
			touch_index = event.index # store our multitouch event index for identifying the touch
			
			if not dragging_stick and (pressed or _pressed):
				dragging_stick = true
				#print_debug("Stick pressed")

	if (event is InputEventScreenDrag) and (touch_index == event.index):
		# While dragging, move the sprite with the mouse.
		#position = event.position
		
		#print_debug("event.screen_relative: " + str(event.screen_relative) + ", last_pos: " + str(last_pos))
		inputVector = event.screen_relative + last_pos
		
		if inputVector.x > click_radius:
			inputVector.x = click_radius
		if inputVector.y > click_radius:
			inputVector.y = click_radius
			
		if inputVector.x < -click_radius:
			inputVector.x = -click_radius
		if inputVector.y < -click_radius:
			inputVector.y = -click_radius
			
		#print_debug("Stick input vector: " + str(inputVector))
		last_pos = position
		position = inputVector
		
		var newInputEventJoyX = InputEventJoypadMotion.new() # Craft our input event for JoyX
		newInputEventJoyX.axis = _joy_axis_x
		newInputEventJoyX.axis_value = inputVector.x / click_radius
		var newInputEventJoyY = InputEventJoypadMotion.new() # Craft our input event for JoyY
		newInputEventJoyY.axis = _joy_axis_y
		newInputEventJoyY.axis_value = inputVector.y / click_radius
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
		_pressed = false
		touch_index = -1
		#print_debug("Stick released [1]")
		# Zero virtual joystick
		var newInputEventJoyX = InputEventJoypadMotion.new()
		newInputEventJoyX.axis = _joy_axis_x
		newInputEventJoyX.axis_value = 0.0
		var newInputEventJoyY = InputEventJoypadMotion.new()
		newInputEventJoyY.axis = _joy_axis_y
		newInputEventJoyY.axis_value = 0.0
		Input.parse_input_event(newInputEventJoyX)
		Input.parse_input_event(newInputEventJoyY)
		return

func _on_press():
	_pressed = true
	return
