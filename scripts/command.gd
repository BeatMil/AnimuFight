class_name Command extends Node


var command_input = []
var pointer = -1
var is_command_complete = false
var is_not_doable = false


func _init(com_i: Array) -> void:
	command_input = com_i


func calculate(_input: String) -> void:
	if is_command_complete:
		pass
	elif _input == command_input[pointer]:
		pointer -= 1
	elif _input == command_input[pointer+1]:
		pass
	else:
		reset()

	if abs(pointer) > len(command_input):
		is_command_complete = true


func get_command_complete() -> bool:
	if is_not_doable:
		return false
	else:
		return is_command_complete


func reset() -> void:
	is_not_doable = false
	is_command_complete = false
	pointer = -1
