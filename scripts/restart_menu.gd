extends Control

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var key_bind_menu: Control = $KeyBindMenu
@onready var v_box_container: VBoxContainer = $VBoxContainer
const MAIN_MENU = preload("res://scenes/main_menu.tscn")


func _ready() -> void:
	key_bind_menu.close.connect(_on_key_bind_menu_close)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_menu()
	elif event.is_action_pressed("ui_cancel"):
		self.visible = false
		get_tree().paused = false
		print("ui_cancel: restart_menu.gd")


func toggle_menu() -> void:
	self.visible = !self.visible
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		resume_button.grab_focus()
		%MenuCursor.move_to(Vector2(778, 500))
		key_bind_menu.visible = false
		v_box_container.visible = true


## used when player dies XD
func open_menu() -> void:
	self.visible = true
	get_tree().paused = true
	restart_button.grab_focus()
	%MenuCursor.move_to(Vector2(778, 530))


func _on_restart_button_pressed() -> void:
	SceneTransition.change_scene(Settings.current_stage)


func _on_main_menu_button_pressed() -> void:
	SceneTransition.change_scene("res://scenes/main_menu.tscn")


func _on_key_bind_button_pressed() -> void:
	key_bind_menu.visible = true
	key_bind_menu.grab_focus_move_left()
	key_bind_menu.display_keys()
	v_box_container.visible = false
	set_process_input(false)


func _on_key_bind_menu_close() -> void:
	key_bind_menu.visible = false
	v_box_container.visible = true
	restart_button.grab_focus()
	%MenuCursor.move_to(Vector2(778, 530))
	set_process_input(true)


func _on_resume_button_pressed() -> void:
	self.visible = false
	get_tree().paused = false
	key_bind_menu.visible = false
	v_box_container.visible = false
