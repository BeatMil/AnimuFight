extends Control
@onready var menu_button: MenuButton = $CanvasLayer/Option/MenuButton
@onready var option: Control = $CanvasLayer/Option


var resolution = {
	0: Vector2(1920, 1080),
	1: Vector2(800, 600),

}


func _ready() -> void:
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


func _on_button_2_button_down() -> void:
	option.visible = !option.visible


func _on_button_3_button_down() -> void:
	get_tree().quit()


func _on_button_start_button_down() -> void:
	SceneTransition.change_scene("res://scenes/intro.tscn")
