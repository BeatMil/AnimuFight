extends "res://scripts/sub_base_menu.gd"

@onready var resume_button: Button = $Group/HBoxContainer/ResumeButton
@onready var restart_button: Button = $Group/HBoxContainer/RestartButton


signal resume_button_press


func remove_resume_button() -> void:
	resume_button.visible = false
	focus_node = restart_button


func _on_resume_button_pressed() -> void:
	emit_signal("resume_button_press")


func _on_restart_button_pressed() -> void:
	SceneTransition.change_scene(Settings.current_stage)


func _on_main_menu_button_pressed() -> void:
	SceneTransition.change_scene("res://scenes/main_menu.tscn")
