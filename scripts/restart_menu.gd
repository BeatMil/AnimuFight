extends Control


@onready var restart_button: Button = $VBoxContainer/RestartButton
const MAIN_MENU = preload("res://scenes/main_menu.tscn")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_menu()


func toggle_menu() -> void:
	self.visible = !self.visible
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		restart_button.grab_focus()
		%MenuCursor.move_to(Vector2(778, 530))


func open_menu() -> void:
	self.visible = true
	get_tree().paused = true
	restart_button.grab_focus()
	%MenuCursor.move_to(Vector2(778, 530))


func _on_restart_button_pressed() -> void:
	SceneTransition.change_scene(Settings.current_stage)


func _on_main_menu_button_pressed() -> void:
	SceneTransition.change_scene_packed(MAIN_MENU)
