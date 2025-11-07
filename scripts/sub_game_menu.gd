extends "res://scripts/sub_base_menu.gd"


signal resume_button_press


func _on_resume_button_pressed() -> void:
	emit_signal("resume_button_press")


func _on_restart_button_pressed() -> void:
	SceneTransition.change_scene(Settings.current_stage)


func _on_main_menu_button_pressed() -> void:
	SceneTransition.change_scene("res://scenes/main_menu.tscn")
