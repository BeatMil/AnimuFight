extends Button
@export var action: String
@export var action_label_show: String
@onready var action_label: Label = $ActionLabel
@onready var key_label: Label = $KeyLabel


func _init():
	toggle_mode = true


func _ready():
	action_label.text = action_label_show
	set_process_unhandled_input(false)
	update_key_text()


func _unhandled_input(event):
	if event.pressed:
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		button_pressed = false


func update_key_text():
	key_label.text = "%s" % InputMap.action_get_events(action)[0].as_text()


func _on_toggled(toggled_on: bool) -> void:
	if button_pressed:
		key_label.text = "... Awaiting Input ..."
		release_focus()
	else:
		update_key_text()
		grab_focus()
	await get_tree().create_timer(0.01).timeout
	set_process_unhandled_input(toggled_on)
