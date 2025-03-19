extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioServer.set_bus_volume_db(0, -7)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		var current_mode = get_viewport().get_window().mode
		if current_mode == 4:
			get_viewport().get_window().mode = 0
		else:
			get_viewport().get_window().mode = 4
