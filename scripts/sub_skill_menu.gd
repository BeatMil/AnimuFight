extends "res://scripts/sub_base_menu.gd"


# @onready var button_2: Button = $Group/VBoxContainer/HBoxContainerR/Button2
# @onready var button: Button = $Group/VBoxContainer/HBoxContainerL/MarginContainer/Button
@onready var player: CharacterBody2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/Player
@onready var player_pos: Marker2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/PlayerPos


func _ready() -> void:
	pass
	player.command_list_dummy()
	player.position = player_pos.position
	player.global_position = player_pos.global_position


func focus_disable() -> void:
	pass
	# button.focus_mode = Control.FOCUS_NONE
	# button_2.focus_mode = Control.FOCUS_NONE


func focus_enable() -> void:
	pass
	# button.focus_mode = Control.FOCUS_ALL
	# button_2.focus_mode = Control.FOCUS_ALL
