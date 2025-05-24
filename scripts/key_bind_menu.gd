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


@onready var press_any_key_screen: ColorRect = $PressAnyKeyScreen
@onready var move_left_button: Button = $HBoxContainer/MoveLeftButton
@onready var move_right_button: Button = $HBoxContainer/MoveRightButton
@onready var jump_button: Button = $HBoxContainer/JumpButton
@onready var light_attack_button: Button = $HBoxContainer/LightAttackButton
@onready var heavy_attack_button: Button = $HBoxContainer/HeavyAttackButton
@onready var block_button: Button = $HBoxContainer/BlockButton
@onready var dodge_button: Button = $HBoxContainer/DodgeButton
@onready var execute_button: Button = $HBoxContainer/ExecuteButton

@onready var left_key_label: Label = $HBoxContainer/MoveLeftButton/LeftKeyLabel
@onready var right_key_label: Label = $HBoxContainer/MoveRightButton/RightKeyLabel
@onready var jump_key_label: Label = $HBoxContainer/JumpButton/JumpKeyLabel
@onready var light_key_label: Label = $HBoxContainer/LightAttackButton/LightKeyLabel
@onready var heavy_key_label: Label = $HBoxContainer/HeavyAttackButton/HeavyKeyLabel
@onready var block_key_label: Label = $HBoxContainer/BlockButton/BlockKeyLabel
@onready var dodge_key_label: Label = $HBoxContainer/DodgeButton/DodgeKeyLabel
@onready var execute_key_label: Label = $HBoxContainer/ExecuteButton/ExecuteKeyLabel


func display_keys() -> void:
	left_key_label.text = ""
	var keys = InputMap.action_get_events("ui_left")
	for key in keys:
		left_key_label.text += key.as_text()

	right_key_label.text = ""
	keys = InputMap.action_get_events("ui_right")
	for key in keys:
		right_key_label.text += key.as_text()

	jump_key_label.text = ""
	keys = InputMap.action_get_events("jump")
	for key in keys:
		jump_key_label.text += key.as_text()

	light_key_label.text = ""
	keys = InputMap.action_get_events("lp")
	for key in keys:
		light_key_label.text += key.as_text()

	heavy_key_label.text = ""
	keys = InputMap.action_get_events("hp")
	for key in keys:
		heavy_key_label.text += key.as_text()

	block_key_label.text = ""
	keys = InputMap.action_get_events("block")
	for key in keys:
		block_key_label.text += key.as_text()

	dodge_key_label.text = ""
	keys = InputMap.action_get_events("dodge")
	for key in keys:
		dodge_key_label.text += key.as_text()

	execute_key_label.text = ""
	keys = InputMap.action_get_events("execute")
	for key in keys:
		execute_key_label.text += key.as_text()


func grab_focus_move_left() -> void:
	move_left_button.grab_focus()


func _ready() -> void:
	move_left_button.grab_focus()
	# InputMap.action_erase_events("jump")
	#InputMap.action_add_event("jump", )


func _input(event: InputEvent) -> void:
	if event.is_pressed() and is_move_left_key_change:
		if event is InputEventJoypadButton:
			if event.button_index == 0 and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		elif event is InputEventKey:
			if event.keycode == KEY_SPACE and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		InputMap.action_erase_events("ui_left")
		InputMap.action_add_event("ui_left", event)
		is_move_left_key_change = false
		left_key_label.text = event.as_text()
		press_any_key_screen.visible = false
		last_focus.grab_focus()

	if event.is_pressed() and is_move_right_key_change:
		if event is InputEventJoypadButton:
			if event.button_index == 0 and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		elif event is InputEventKey:
			if event.keycode == KEY_SPACE and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		InputMap.action_erase_events("ui_right")
		InputMap.action_add_event("ui_right", event)
		is_move_right_key_change = false
		right_key_label.text = event.as_text()
		press_any_key_screen.visible = false
		last_focus.grab_focus()

	if event.is_pressed() and is_jump_key_change:
		if event is InputEventJoypadButton:
			if event.button_index == 0 and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		elif event is InputEventKey:
			if event.keycode == KEY_SPACE and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		InputMap.action_erase_events("jump")
		InputMap.action_add_event("jump", event)
		is_jump_key_change = false
		jump_key_label.text = event.as_text()
		press_any_key_screen.visible = false
		last_focus.grab_focus()

	if event.is_pressed() and is_light_attack_key_change:
		if event is InputEventJoypadButton:
			if event.button_index == 0 and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		elif event is InputEventKey:
			if event.keycode == KEY_SPACE and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		InputMap.action_erase_events("lp")
		InputMap.action_add_event("lp", event)
		is_light_attack_key_change = false
		light_key_label.text = event.as_text()
		press_any_key_screen.visible = false
		last_focus.grab_focus()

	if event.is_pressed() and is_heavy_attack_key_change:
		if event is InputEventJoypadButton:
			if event.button_index == 0 and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		elif event is InputEventKey:
			if event.keycode == KEY_SPACE and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		InputMap.action_erase_events("hp")
		InputMap.action_add_event("hp", event)
		is_heavy_attack_key_change = false
		heavy_key_label.text = event.as_text()
		press_any_key_screen.visible = false
		last_focus.grab_focus()

	if event.is_pressed() and is_block_key_change:
		if event is InputEventJoypadButton:
			if event.button_index == 0 and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		elif event is InputEventKey:
			if event.keycode == KEY_SPACE and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		InputMap.action_erase_events("block")
		InputMap.action_add_event("block", event)
		is_block_key_change = false
		block_key_label.text = event.as_text()
		press_any_key_screen.visible = false
		last_focus.grab_focus()

	if event.is_pressed() and is_dodge_key_change:
		if event is InputEventJoypadButton:
			if event.button_index == 0 and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		elif event is InputEventKey:
			if event.keycode == KEY_SPACE and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		InputMap.action_erase_events("dodge")
		InputMap.action_add_event("dodge", event)
		is_dodge_key_change = false
		dodge_key_label.text = event.as_text()
		press_any_key_screen.visible = false
		last_focus.grab_focus()

	if event.is_pressed() and is_execute_key_change:
		if event is InputEventJoypadButton:
			if event.button_index == 0 and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		elif event is InputEventKey:
			if event.keycode == KEY_SPACE and event.pressed:
				await get_tree().create_timer(0.1).timeout
				press_any_key_screen.visible = false
		InputMap.action_erase_events("execute")
		InputMap.action_add_event("execute", event)
		is_execute_key_change = false
		execute_key_label.text = event.as_text()
		press_any_key_screen.visible = false
		last_focus.grab_focus()


func _on_move_left_button_pressed() -> void:
	is_move_left_key_change = true
	press_any_key_screen.visible = true
	press_any_key_screen.grab_focus()
	last_focus = move_left_button


func _on_move_right_button_pressed() -> void:
	is_move_right_key_change = true
	press_any_key_screen.visible = true
	press_any_key_screen.grab_focus()
	last_focus = move_right_button


func _on_jump_button_pressed() -> void:
	is_jump_key_change = true
	press_any_key_screen.visible = true
	press_any_key_screen.grab_focus()
	last_focus = jump_button


func _on_light_attack_button_pressed() -> void:
	is_light_attack_key_change = true
	press_any_key_screen.visible = true
	press_any_key_screen.grab_focus()
	last_focus = light_attack_button


func _on_heavy_attack_button_pressed() -> void:
	is_heavy_attack_key_change = true
	press_any_key_screen.visible = true
	press_any_key_screen.grab_focus()
	last_focus = heavy_attack_button


func _on_block_button_pressed() -> void:
	is_block_key_change = true
	press_any_key_screen.visible = true
	press_any_key_screen.grab_focus()
	last_focus = block_button


func _on_dodge_button_pressed() -> void:
	is_dodge_key_change = true
	press_any_key_screen.visible = true
	press_any_key_screen.grab_focus()
	last_focus = dodge_button


func _on_back_button_pressed() -> void:
	emit_signal("close")


func _on_execute_button_pressed() -> void:
	is_execute_key_change = true
	press_any_key_screen.visible = true
	press_any_key_screen.grab_focus()
	last_focus = execute_button
