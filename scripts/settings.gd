extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioServer.set_bus_volume_db(0, -7)
	print(AudioServer.get_bus_volume_db(0))
