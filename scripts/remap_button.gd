extends Button
@export var action: String
@export var action_label_show: String
@onready var key_label: Label = $HBoxContainer/KeyLabel
@onready var controller_label: Label = $HBoxContainer/ControllerLabel
@onready var action_label: Label = $HBoxContainer/ActionLabel


func _init():
	toggle_mode = true


func _ready():
	action_label.text = action_label_show
	set_process_unhandled_input(false)
	update_key_text()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		if event.axis_value < 0.4: # prevent accident bind
			return
		for current in InputMap.action_get_events(action):
			if (current is InputEventJoypadMotion) or (current is InputEventJoypadButton):
				InputMap.action_erase_event(action, current)
				InputMap.action_add_event(action, event)
				button_pressed = false
				get_parent().get_parent().set_process_input(true)
	elif event.is_pressed():
		if InputMap.event_is_action(event, action):
			print("Duplicate keybind ABORT!")
		else:
			if event is InputEventJoypadButton:
				for current in InputMap.action_get_events(action):
					if (current is InputEventJoypadMotion) or \
						(current is InputEventJoypadButton):
						InputMap.action_erase_event(action, current)
						InputMap.action_add_event(action, event)
			if event is InputEventKey:
				for current in InputMap.action_get_events(action):
					if current is InputEventKey:
						InputMap.action_erase_event(action, current)
						InputMap.action_add_event(action, event)
		button_pressed = false
		get_parent().get_parent().set_process_input(true)


func update_key_text():
	for i in InputMap.action_get_events(action):
		if (i is InputEventJoypadButton) or (i is InputEventJoypadMotion):
			var start_index = i.as_text().find("(")
			var beatify_string = \
			i.as_text().substr(start_index)
			controller_label.text = "%s" % beatify_string
		else:
			var keyboard = OS.get_keycode_string(i.keycode)
			key_label.text = "%s" % keyboard
	


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# InputMap.action_erase_events(action)
		get_parent().get_parent().set_process_input(false)
		key_label.text = "... Awaiting Input ..."
		release_focus()
	else:
		update_key_text()
		grab_focus()
	await get_tree().create_timer(0.01).timeout
	set_process_unhandled_input(toggled_on)
