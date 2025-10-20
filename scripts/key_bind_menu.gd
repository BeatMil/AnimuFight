extends Control

signal close


var is_jump_key_change: bool = false

var is_move_left_key_change: bool = false
var is_move_right_key_change: bool = false
var is_light_attack_key_change: bool = false
var is_heavy_attack_key_change: bool = false
var is_block_key_change: bool = false
var is_dodge_key_change: bool = false
var is_execute_key_change: bool = false

var last_focus: Object
var action: String
var button_pressed = false
@onready var h_box_container: VBoxContainer = $HBoxContainer
@onready var press_any_key_screen: ColorRect = $PressAnyKeyScreen
@onready var move_left_button: Button = $HBoxContainer/MoveLeftButton



func display_keys() -> void:
	for button in h_box_container.get_children():
		if button.has_method("update_key_text"):
			button.update_key_text()


func grab_focus_move_left() -> void:
	move_left_button.grab_focus()


func _ready() -> void:
	pass
	# move_left_button.grab_focus()
	# set_process_unhandled_input(false)
	# InputMap.action_erase_events("jump")
	#InputMap.action_add_event("jump", )


func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("ui_cancel"):
			emit_signal("close")


func _on_back_button_pressed() -> void:
	emit_signal("close")
	var actions = [
		"left",
		"right",
		"up",
		"down",
		"dash",
		"lp",
		"hp",
		"block",
		"dodge",
		"execute",
	]
	for a in actions:
		print(InputMap.action_get_events(a)[0], a)
