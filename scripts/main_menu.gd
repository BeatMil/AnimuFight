extends Control
@onready var menu_button: MenuButton = $CanvasLayer/Option/MenuButton
@onready var option: Control = $CanvasLayer/Option
@onready var start_button: Button = $CanvasLayer/VBoxContainer/StartButton


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
	pass


func _on_menu_button_about_to_popup() -> void:
	print("==bob==")
	# change_resolution()


func change_resolution(id: int) -> void:
	print("ID: ", id)
	# DisplayServer.window_set_size(resolution[id])
	get_viewport().get_window().size = resolution[id]
	print(DisplayServer.window_get_size())


func _on_start_button_pressed() -> void:
	SceneTransition.change_scene("res://scenes/intro.tscn")


func _on_option_button_pressed() -> void:
	option.visible = !option.visible


func _on_quit_button_pressed() -> void:
	get_tree().quit()
