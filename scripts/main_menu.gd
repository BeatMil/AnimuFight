extends Control


@onready var menu_button: MenuButton = $CanvasLayer/Option/MenuButton
@onready var option: Control = $CanvasLayer/Option
@onready var start_button: Button = $CanvasLayer/VBoxContainer/StartButton
const TRAINING_MODE = preload("res://scenes/training.tscn")
const TUTORIAL = preload("res://scenes/tutorial.tscn")
const INTRO = preload("res://scenes/intro.tscn")
@onready var key_bind_menu: Control = $CanvasLayer/KeyBindMenu
@onready var change_key_bind_button: Button = $CanvasLayer/Option/ChangeKeyBindButton
@onready var option_button: Button = $CanvasLayer/VBoxContainer/OptionButton


var resolution = {
	0: Vector2(1920, 1080),
	1: Vector2(800, 600),
}


func _ready() -> void:
	start_button.grab_focus()
	%MenuCursor.move_to(Vector2(160, 768))
	print(DisplayServer.window_get_size())
	# id_pressed
	menu_button.get_popup().id_pressed.connect(change_resolution)
	key_bind_menu.close.connect(_on_key_bind_menu_close)
	AttackQueue.start_queue_timer()
	Settings.checkpoint = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		option.visible = false
		key_bind_menu.visible = false
		option_button.grab_focus()

func _on_menu_button_about_to_popup() -> void:
	pass
	# change_resolution()


func change_resolution(id: int) -> void:
	print("ID: ", id)
	# DisplayServer.window_set_size(resolution[id])
	get_viewport().get_window().size = resolution[id]
	print(DisplayServer.window_get_size())


func _on_start_button_pressed() -> void:
	SceneTransition.change_scene_packed(INTRO)


func _on_option_button_pressed() -> void:
	option.visible = true
	change_key_bind_button.grab_focus()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_training_button_pressed() -> void:
	SceneTransition.change_scene_packed(TRAINING_MODE)


func _on_change_key_bind_button_pressed() -> void:
	key_bind_menu.visible = true
	key_bind_menu.grab_focus_move_left()
	key_bind_menu.display_keys()


func _on_key_bind_menu_close() -> void:
	key_bind_menu.visible = false
	change_key_bind_button.grab_focus()


func _on_back_button_pressed() -> void:
	option.visible = false
	option_button.grab_focus()


func _on_tutorial_button_pressed() -> void:
	SceneTransition.change_scene_packed(TUTORIAL)
