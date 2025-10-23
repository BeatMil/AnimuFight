extends Node

const XBOX_A = preload("uid://bw0qeoor72v84")
const XBOX_B = preload("uid://c5ium03im68gh")
const XBOX_X = preload("uid://blhaq35ymebhd")
const XBOX_Y = preload("uid://bo7ct5287xbyl")

const PS_CIRCLE = preload("uid://c6fj2i3n1io2g")
const PS_SQUARE = preload("uid://cf0jll63rq0ti")
const PS_TRIANGLE = preload("uid://clwfsefeaeb5y")
const PS_X = preload("uid://wi6kjr7oshdd")

signal input_recieved
signal send_controller_icon

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
				emit_signal("send_controller_icon", get_controller_icon(e.button_index))
	# emit_signal("input_recieved", human_read)
	# for e in InputMap.action_get_events(action):


func get_controller_icon(button_index: int) -> Object:
	var the_object

	if Settings.controller_type == Settings.ControllerType.XBOX:
		match button_index:
			JOY_BUTTON_A:
				the_object = XBOX_A
			JOY_BUTTON_B:
				the_object = XBOX_B
			JOY_BUTTON_X:
				the_object = XBOX_X
			JOY_BUTTON_Y:
				the_object = XBOX_Y
			_:
				pass
	elif Settings.controller_type == Settings.ControllerType.PS:
		match button_index:
			JOY_BUTTON_A:
				the_object = PS_X
			JOY_BUTTON_B:
				the_object = PS_CIRCLE
			JOY_BUTTON_X:
				the_object = PS_SQUARE
			JOY_BUTTON_Y:
				the_object = PS_TRIANGLE
			_:
				pass

	return the_object


func get_input_source() -> int:
	return _input_source
