extends Control

var command: String
var frame: int = 0

@onready var direction_label: Label = $HBoxContainer/DirectionLabel
@onready var frame_label: Label = $HBoxContainer/FrameLabel


func _ready() -> void:
	direction_label.text = command
	frame_label.text = str(frame)


func increament_frame() -> void:
	frame += 1
	frame_label.text = str(frame)
