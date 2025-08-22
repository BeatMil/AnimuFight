extends Control

var command: String
var frame: int = 0

@onready var direction_label: Label = $HBoxContainer/DirectionLabel
@onready var frame_label: Label = $HBoxContainer/FrameLabel
@onready var arrow_right: Sprite2D = $HBoxContainer/CommandImage/ArrowRight
@onready var h_button: Sprite2D = $HBoxContainer/CommandImage/HButton
@onready var l_button: Sprite2D = $HBoxContainer/CommandImage/LButton


func _ready() -> void:
	direction_label.text = command
	match command[0]:
		"9":
			arrow_right.flip_h = true
			arrow_right.rotate(PI - (PI/4))
		"8":
			arrow_right.flip_h = true
			arrow_right.rotate(PI / 2)
		"7":
			arrow_right.flip_h = true
			arrow_right.rotate(PI / 4)
		"6":
			arrow_right.visible = true
		"5":
			arrow_right.visible = false
		"4":
			arrow_right.flip_h = true
		"3":
			arrow_right.rotate(PI / 4)
		"2":
			arrow_right.rotate(PI / 2)
		"1":
			arrow_right.rotate(PI - (PI/4))

	if command.find("l") < 0:
		l_button.visible = false
	if command.find("h") < 0:
		h_button.visible = false

	frame_label.text = str(frame)


func increament_frame() -> void:
	frame += 1
	frame_label.text = str(frame)
