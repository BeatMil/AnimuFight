extends Node


signal input_recieved

var action: String = "lp"


enum InputSource {
	KEYBOARD,
	CONTROLLER
}


var _input_source = InputSource.KEYBOARD


func _input(event: InputEvent) -> void:
	var human_read
	if event is InputEventKey or event is InputEventMouse:
		_input_source = InputSource.KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		_input_source = InputSource.CONTROLLER

	if event is InputEventKey or event is InputEventMouse:
		for e in InputMap.action_get_events(action):
			if e is InputEventKey:
				human_read = OS.get_keycode_string(e.keycode)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		for e in InputMap.action_get_events(action):
			if e is InputEventJoypadButton:
				human_read = e.button_index
	emit_signal("input_recieved", human_read)
	# for e in InputMap.action_get_events(action):


func get_input_source() -> int:
	return _input_source
