extends Node

const XBOX_A = preload("uid://bw0qeoor72v84")
const XBOX_B = preload("uid://c5ium03im68gh")
const XBOX_X = preload("uid://blhaq35ymebhd")
const XBOX_Y = preload("uid://bo7ct5287xbyl")
const XBOX_D_DOWN = preload("uid://revgc854v4ye")
const XBOX_D_LEFT = preload("uid://bm8vaskighqct")
const XBOX_D_RIGHT = preload("uid://b3da0at7cebki")
const XBOX_D_UP = preload("uid://dx32dwycd3qn8")
const XBOX_L_3 = preload("uid://0isqcomeuicm")
const XBOX_LB = preload("uid://u3b5wd0rmkg5")
const XBOX_LT = preload("uid://bpshlcb1tb067")
const XBOX_R_3 = preload("uid://s7ikecd41a8w")
const XBOX_RB = preload("uid://ct1ikwqitscd7")
const XBOX_RT = preload("uid://bjsltq3v2al7")
const XBOX_SELECT = preload("uid://bdovv3ofoo5it")
const XBOX_START = preload("uid://c02ak6paehblu")

const PS_CIRCLE = preload("uid://c6fj2i3n1io2g")
const PS_SQUARE = preload("uid://cf0jll63rq0ti")
const PS_TRIANGLE = preload("uid://clwfsefeaeb5y")
const PS_X = preload("uid://wi6kjr7oshdd")
const PS_L_1 = preload("uid://c8jpf38twofe3")
const PS_L_2 = preload("uid://dw1f61qtr85qr")
const PS_L_3 = preload("uid://bvu4e4tsw6jsh")
const PS_R_1 = preload("uid://dbrrps3gju1yg")
const PS_R_2 = preload("uid://cegntcyxpd872")
const PS_R_3 = preload("uid://6fxhvl68jien")
const PS_SELECT = preload("uid://c50ts218ty8xq")
const PS_START = preload("uid://dcecty12kc4j3")

const KB_0 = preload("uid://brxy16uuald0v")
const KB_1 = preload("uid://btpaw60s40ymb")
const KB_2 = preload("uid://ia13f5sbax5j")
const KB_3 = preload("uid://dipris0ak2rg4")
const KB_4 = preload("uid://dvxwuis7tv2fn")
const KB_5 = preload("uid://pcs1f6eimjhc")
const KB_6 = preload("uid://co477o1155aik")
const KB_7 = preload("uid://c7hvgk0d3pmtr")
const KB_8 = preload("uid://bc2iguusffdwe")
const KB_9 = preload("uid://8edspld1yijs")
const KB_A = preload("uid://bs6abknycknrv")
const KB_ALT = preload("uid://b2q50xdwwm4fc")
const KB_B = preload("uid://cw1dif218fkdc")
const KB_BACKSLASH = preload("uid://ckrw05ji0ypb1")
const KB_BACKSPACE = preload("uid://d3rvks713lxt0")
const KB_C = preload("uid://dmdi66p1gxaw")
const KB_CAPS = preload("uid://rsbdow7r4eh")
const KB_CLOSE_BRACKET = preload("uid://c1uusd2l2rskw")
const KB_CTRL = preload("uid://bfpss58s5fybv")
const KB_D = preload("uid://d0b14h4m81c76")
const KB_DEL = preload("uid://cccj7hv0iput0")
const KB_DOT = preload("uid://c25vv4kp534h0")
const KB_E = preload("uid://dmyjdajqursh7")
const KB_END = preload("uid://y8df35kptpxc")
const KB_ENTER = preload("uid://bk3tsx4c13f3r")
const KB_F_1 = preload("uid://q3mrsi8wsk4w")
const KB_F_2 = preload("uid://hduceac4eh1u")
const KB_F_3 = preload("uid://bik2bb6a48vq7")
const KB_F_4 = preload("uid://dg4658af2ydqh")
const KB_F_5 = preload("uid://dd0h0gvoymoli")
const KB_F_6 = preload("uid://dyuwyvd3wwrgr")
const KB_F_7 = preload("uid://cr8tf0vecth6n")
const KB_F_8 = preload("uid://d3cm0oohf023w")
const KB_F_9 = preload("uid://m5slbesut7nr")
const KB_F_10 = preload("uid://dsldclkw81lxd")
const KB_F_11 = preload("uid://cl0r2ohylddc3")
const KB_F_12 = preload("uid://mdrqptptefps")
const KB_F = preload("uid://dpsqf7mdjg6ed")
const KB_FORWARD_SLASH = preload("uid://cr4v21vgpxwsc")
const KB_G = preload("uid://h0q5peaw2smp")
const KB_H = preload("uid://d3bw7qaafrrs4")
const KB_HOME = preload("uid://cwunju6lhuk1j")
const KB_I = preload("uid://cuby20pxqjr4m")
const KB_J = preload("uid://bpngwsmsve5gg")
const KB_K = preload("uid://dllto57j0wp1y")
const KB_L = preload("uid://dsxwkf5shavc")
const KB_M = preload("uid://doy2dbki1e2wg")
const KB_MINUS = preload("uid://baj1ki668pxr7")
const KB_N = preload("uid://conu1g2ke0kbn")
const KB_O = preload("uid://bvtqs3as6qtl6")
const KB_OPEN_BRACKET = preload("uid://c8sb6tpu74yfk")
const KB_P = preload("uid://0ry57sct7pjb")
const KB_PGDN = preload("uid://cxj6kmkw0oqkx")
const KB_PGUP = preload("uid://doykdnf5omjtk")
const KB_Q = preload("uid://lbik1mdiq50e")
const KB_QUOTE = preload("uid://cnpskdcuj2uhw")
const KB_R = preload("uid://c8njxo3dpy0pp")
const KB_S = preload("uid://dsa37l6ps5664")
const KB_SEMI_COLON = preload("uid://cjkml1i1c45r3")
const KB_SHIFT = preload("uid://c8wvv5ci8vwf8")
const KB_SPACE = preload("uid://dm3iss41kfdwe")
const KB_T = preload("uid://b8jvyy6yg0fvp")
const KB_U = preload("uid://c8e2yq5ljih5g")
const KB_V = preload("uid://b5j2ucy6ks24p")
const KB_W = preload("uid://wncw1pafdmrr")
const KB_X = preload("uid://bkbrgjf2kflmv")
const KB_Y = preload("uid://u8ysksuwenrn")
const KB_Z = preload("uid://cevpgu7a2km8k")
const KB_ESC = preload("uid://betolyhlb3qx0")
const KB_INSERT = preload("uid://bfrarfcqqg6lj")
const KB_DOWN = preload("uid://bulr3a0iduegh")
const KB_LEFT = preload("uid://b70u6wjoqjkqx")
const KB_RIGHT = preload("uid://dhnn432dn5mpj")
const KB_UP = preload("uid://bhsr0g4ek57cd")

signal input_recieved
signal send_controller_icon
signal send_keyboard_icon
signal send_icon

var action: String = "lp"


enum InputSource {
	KEYBOARD,
	CONTROLLER
}


var _input_source = InputSource.KEYBOARD


func _input(event: InputEvent) -> void:
	var human_read
	var icon
	if event is InputEventKey or event is InputEventMouse:
		_input_source = InputSource.KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		_input_source = InputSource.CONTROLLER

	if event is InputEventKey or event is InputEventMouse:
		for e in InputMap.action_get_events(action):
			if e is InputEventKey:
				human_read = OS.get_keycode_string(e.keycode)
				icon = get_keyboard_icon(e.keycode)
				emit_signal("send_keyboard_icon", get_keyboard_icon(e.keycode))
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		for e in InputMap.action_get_events(action):
			if e is InputEventJoypadButton:
				human_read = e.button_index
				icon = get_controller_icon(e.button_index)
				emit_signal("send_controller_icon", get_controller_icon(e.button_index))
	emit_signal("input_recieved", human_read)
	emit_signal("send_icon", icon)


func get_icon_from_action(_action: String) -> Object:
	if _input_source == InputSource.KEYBOARD:
		for e in InputMap.action_get_events(_action):
			if e is InputEventKey:
				return get_keyboard_icon(e.keycode)
	elif _input_source == InputSource.CONTROLLER:
		for e in InputMap.action_get_events(_action):
			if e is InputEventJoypadButton or e is InputEventJoypadMotion:
				return get_controller_icon(e.button_index)
	return Object


func get_keyboard_icon(keycode: int) -> Object:
	var the_object
	match keycode:
		KEY_0:
			the_object = KB_0
		KEY_1:
			the_object = KB_1
		KEY_2:
			the_object = KB_2
		KEY_3:
			the_object = KB_3
		KEY_4:
			the_object = KB_4
		KEY_5:
			the_object = KB_5
		KEY_6:
			the_object = KB_6
		KEY_7:
			the_object = KB_7
		KEY_8:
			the_object = KB_8
		KEY_9:
			the_object = KB_9
		KEY_KP_0:
			the_object = KB_0
		KEY_KP_1:
			the_object = KB_1
		KEY_KP_2:
			the_object = KB_2
		KEY_KP_3:
			the_object = KB_3
		KEY_KP_4:
			the_object = KB_4
		KEY_KP_5:
			the_object = KB_5
		KEY_KP_6:
			the_object = KB_6
		KEY_KP_7:
			the_object = KB_7
		KEY_KP_8:
			the_object = KB_8
		KEY_KP_9:
			the_object = KB_9
		KEY_A:
			the_object = KB_A
		KEY_B:
			the_object = KB_B
		KEY_C:
			the_object = KB_C
		KEY_D:
			the_object = KB_D
		KEY_E:
			the_object = KB_E
		KEY_F:
			the_object = KB_F
		KEY_G:
			the_object = KB_G
		KEY_H:
			the_object = KB_H
		KEY_I:
			the_object = KB_I
		KEY_J:
			the_object = KB_J
		KEY_K:
			the_object = KB_K
		KEY_L:
			the_object = KB_L
		KEY_M:
			the_object = KB_M
		KEY_N:
			the_object = KB_N
		KEY_O:
			the_object = KB_O
		KEY_P:
			the_object = KB_P
		KEY_Q:
			the_object = KB_Q
		KEY_R:
			the_object = KB_R
		KEY_S:
			the_object = KB_S
		KEY_T:
			the_object = KB_T
		KEY_U:
			the_object = KB_U
		KEY_V:
			the_object = KB_V
		KEY_W:
			the_object = KB_W
		KEY_S:
			the_object = KB_S
		KEY_Y:
			the_object = KB_Y
		KEY_Z:
			the_object = KB_Z
		KEY_Z:
			the_object = KB_Z
		KEY_SPACE:
			the_object = KB_SPACE
		KEY_HOME:
			the_object = KB_HOME
		KEY_INSERT:
			the_object = KB_INSERT
		KEY_PAGEDOWN:
			the_object = KB_PGDN
		KEY_END:
			the_object = KB_END
		KEY_PAGEUP:
			the_object = KB_PGUP
		KEY_CAPSLOCK:
			the_object = KB_CAPS
		KEY_SHIFT:
			the_object = KB_SHIFT
		KEY_ALT:
			the_object = KB_ALT
		KEY_CTRL:
			the_object = KB_CTRL
		KEY_BACKSPACE:
			the_object = KB_BACKSPACE
		KEY_ENTER:
			the_object = KB_ENTER
		KEY_ESCAPE:
			the_object = KB_ESC
		KEY_DELETE:
			the_object = KB_DEL
		KEY_F1:
			the_object = KB_F_1
		KEY_F2:
			the_object = KB_F_2
		KEY_F3:
			the_object = KB_F_3
		KEY_F4:
			the_object = KB_F_4
		KEY_F5:
			the_object = KB_F_5
		KEY_F6:
			the_object = KB_F_6
		KEY_F7:
			the_object = KB_F_7
		KEY_F8:
			the_object = KB_F_8
		KEY_F9:
			the_object = KB_F_9
		KEY_F10:
			the_object = KB_F_10
		KEY_F11:
			the_object = KB_F_11
		KEY_F12:
			the_object = KB_F_12
		KEY_BACKSLASH:
			the_object = KB_BACKSLASH
		KEY_SLASH:
			the_object = KB_FORWARD_SLASH
		KEY_BRACKETLEFT:
			the_object = KB_OPEN_BRACKET
		KEY_BRACKETRIGHT:
			the_object = KB_CLOSE_BRACKET
		KEY_MINUS:
			the_object = KB_MINUS
		KEY_KP_SUBTRACT:
			the_object = KB_MINUS
		KEY_PERIOD:
			the_object = KB_DOT
		KEY_KP_PERIOD:
			the_object = KB_DOT
		KEY_SEMICOLON:
			the_object = KB_SEMI_COLON
		KEY_QUOTELEFT:
			the_object = KB_QUOTE
		KEY_LEFT:
			the_object = KB_LEFT
		KEY_RIGHT:
			the_object = KB_RIGHT
		KEY_UP:
			the_object = KB_UP
		KEY_DOWN:
			the_object = KB_DOWN
		_:
			pass
	return the_object


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
			JOY_BUTTON_BACK:
				the_object = XBOX_SELECT
			JOY_BUTTON_START:
				the_object = XBOX_START
			JOY_BUTTON_LEFT_STICK:
				the_object = XBOX_L_3
			JOY_BUTTON_RIGHT_STICK:
				the_object = XBOX_R_3
			JOY_BUTTON_LEFT_SHOULDER:
				the_object = XBOX_LB
			JOY_BUTTON_RIGHT_SHOULDER:
				the_object = XBOX_RB
			JOY_BUTTON_DPAD_UP:
				the_object = XBOX_D_UP
			JOY_BUTTON_DPAD_DOWN:
				the_object = XBOX_D_DOWN
			JOY_BUTTON_DPAD_LEFT:
				the_object = XBOX_D_LEFT
			JOY_BUTTON_DPAD_RIGHT:
				the_object = XBOX_D_RIGHT
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
			JOY_BUTTON_BACK:
				the_object = PS_SELECT
			JOY_BUTTON_START:
				the_object = PS_START
			JOY_BUTTON_LEFT_STICK:
				the_object = PS_L_3
			JOY_BUTTON_RIGHT_STICK:
				the_object = PS_R_3
			JOY_BUTTON_LEFT_SHOULDER:
				the_object = PS_L_1
			JOY_BUTTON_RIGHT_SHOULDER:
				the_object = PS_R_1
			JOY_BUTTON_DPAD_UP:
				the_object = XBOX_D_UP
			JOY_BUTTON_DPAD_DOWN:
				the_object = XBOX_D_DOWN
			JOY_BUTTON_DPAD_LEFT:
				the_object = XBOX_D_LEFT
			JOY_BUTTON_DPAD_RIGHT:
				the_object = XBOX_D_RIGHT
			_:
				pass
	return the_object

func get_controller_axis_icon(axis: int, axis_value: float) -> Object:
	var the_object

	match axis:
		JOY_AXIS_LEFT_X:
			if axis_value > 0:
				the_object = XBOX_D_RIGHT
			else:
				the_object = XBOX_D_LEFT
		JOY_AXIS_LEFT_Y:
			if axis_value > 0:
				the_object = XBOX_D_DOWN
			else:
				the_object = XBOX_D_UP
		JOY_AXIS_TRIGGER_LEFT:
			if Settings.controller_type == Settings.ControllerType.XBOX:
				the_object = XBOX_LT
			elif Settings.controller_type == Settings.ControllerType.PS:
				the_object = PS_L_2
		JOY_AXIS_TRIGGER_RIGHT:
			if Settings.controller_type == Settings.ControllerType.XBOX:
				the_object = XBOX_RT
			elif Settings.controller_type == Settings.ControllerType.PS:
				the_object = PS_R_2
		_:
			pass

	return the_object


func get_input_source() -> int:
	return _input_source
