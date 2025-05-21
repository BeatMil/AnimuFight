extends Control


var is_jump_key_change: bool = false
@onready var jump_key_label: Label = $VBoxContainer/Button1/JumpButton/JumpKeyLabel
@onready var press_any_key_screen: ColorRect = $PressAnyKeyScreen
@onready var jump_button: Button = $VBoxContainer/Button1/JumpButton


func _ready() -> void:
	jump_button.grab_focus()
	pass
	# InputMap.action_erase_events("jump")
	#InputMap.action_add_event("jump", )


func _input(event: InputEvent) -> void:
	if event.is_pressed() and is_jump_key_change:
			InputMap.action_erase_events("jump")
			InputMap.action_add_event("jump", event)
			is_jump_key_change = false
			jump_key_label.text = event.as_text()
			press_any_key_screen.visible = false
			# $ColorRect2/Button/JumpKeyLabel.text = event.as_text()
			# $ColorRect2/Button.release_focus()


func _on_jump_button_pressed() -> void:
	is_jump_key_change = true
	press_any_key_screen.visible = true
